package net.metadata.auselit.lorestore.servlet;

import java.io.InputStream;
import java.io.Writer;

import javax.servlet.http.HttpServletResponse;

import net.metadata.auselit.lorestore.access.OREAccessPolicy;
import net.metadata.auselit.lorestore.model.UploadItem;
import net.metadata.auselit.lorestore.servlet.rdf2go.RDF2GoOREQueryHandler;
import net.metadata.auselit.lorestore.servlet.rdf2go.RDF2GoOREUpdateHandler;

import org.apache.log4j.Logger;
import org.openrdf.rio.RDFFormat;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.validation.ObjectError;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseStatus;

import au.edu.diasb.chico.mvc.RequestFailureException;

@Controller
public class OREAdminController {
	private final Logger LOG = Logger.getLogger(OREAdminController.class);

	private final OREControllerConfig occ;
	private OREUpdateHandler uh;
	private OREQueryHandler qh;
	private OREAccessPolicy ap;

	public OREAdminController(OREControllerConfig occ) {
		this.occ = occ;
		this.uh = new RDF2GoOREUpdateHandler(occ);
		this.qh = new RDF2GoOREQueryHandler(occ);
		this.ap = occ.getAccessPolicy();
	}

	@RequestMapping(value = "/", method = RequestMethod.GET)
	public String index(Model model) {
		ap.checkAdmin();
		model.addAttribute("someText", "Wow, lets see if this text makes it through!");
		return "admin/index";
	}
	
	@RequestMapping(value = "/import", method = RequestMethod.GET)
	public String importData(Model model) {
		ap.checkAdmin();
		model.addAttribute(new UploadItem());
		return "admin/importForm";
	}
	
	@RequestMapping(value = "/import", method = RequestMethod.POST)
	public String bulkImport(UploadItem uploadItem, BindingResult result) throws Exception {
		ap.checkAdmin();
		if (result.hasErrors()) {
			for (ObjectError error : result.getAllErrors()) {
				LOG.error("Error: " + error.getCode() +   " - " + error.getDefaultMessage());
				return "admin/importForm";
			}
		}
		// Some type of file processing
		InputStream fileData = uploadItem.getFileData().getInputStream();
		String originalFilename = uploadItem.getFileData().getOriginalFilename();
		uh.bulkImport(fileData, originalFilename);

		return "redirect:/ore/admin/";
	}
	
	@RequestMapping(value = "/stats", method = RequestMethod.GET)
	public String getStats(Model model) throws InterruptedException, RequestFailureException {
		ap.checkAdmin();
		model.addAttribute("numTriples",qh.getNumberTriples());
		
		return "admin/stats";
	}
	
	@RequestMapping(value = "/wipeDatabase", method = RequestMethod.GET)
	public String confirmWipe() throws RequestFailureException {
		ap.checkAdmin();
		return "admin/confirmWipe";
	}
	
	@RequestMapping(value = "/wipeDatabase", method = RequestMethod.POST)
	public String wipeDatabase() throws InterruptedException, RequestFailureException {
		ap.checkAdmin();
		uh.wipeDatabase();
		return "redirect:/ore/admin/";
	}

	@RequestMapping(value = "/export")
	public void export(HttpServletResponse response) throws Exception {
		response.setContentType(RDFFormat.TRIG.getDefaultMIMEType());
		String filename = "export." + RDFFormat.TRIG.getDefaultFileExtension();
		response.setHeader("Content-Disposition", "attachment; filename="+filename);
		Writer outputWriter = response.getWriter();
		qh.exportAll(outputWriter);
	}
	
	@ResponseStatus(HttpStatus.UNAUTHORIZED)
	@ExceptionHandler({ RequestFailureException.class })
	public void return404() {
		LOG.debug("Handling RequestFailureException, returning 401");
	}

	public OREControllerConfig getControllerConfig() {
		return occ;
	}
}
