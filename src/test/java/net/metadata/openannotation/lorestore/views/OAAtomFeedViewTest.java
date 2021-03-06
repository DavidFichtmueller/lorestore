package net.metadata.openannotation.lorestore.views;

import static org.junit.Assert.assertEquals;

import java.io.ByteArrayInputStream;
import java.util.ArrayList;

import net.metadata.openannotation.lorestore.servlet.CommonTestRecords;
import net.metadata.openannotation.misc.TestUtilities;

import org.junit.Before;
import org.junit.Test;
import org.ontoware.rdf2go.model.Model;
import org.springframework.mock.web.MockHttpServletRequest;
import org.springframework.mock.web.MockHttpServletResponse;
import org.springframework.web.servlet.ModelAndView;

public class OAAtomFeedViewTest {
	private MockHttpServletRequest request;
	private MockHttpServletResponse response;
	private ModelAndView mv;
	private OAAtomFeedView view;

	@Before
	public void setUp() throws Exception {
		Model model1 = TestUtilities.create(new ByteArrayInputStream(
				CommonTestRecords.OAC_WITH_PROPS.getBytes()),
				"http://example.com/oac/");
		Model model2 = TestUtilities.create(new ByteArrayInputStream(
				CommonTestRecords.OAC_WITH_OWNER.getBytes()),
				"http://example.com/oac/");
		
		ArrayList<Model> annotations = new ArrayList<Model>();
		annotations.add(model1);
		annotations.add(model2);
		
		view = new OAAtomFeedView();
		mv = new ModelAndView("oaAtom");
		mv.addObject("annotationlist",annotations);
		request = new MockHttpServletRequest();
		response = new MockHttpServletResponse();
	}

	@Test
	public void constructorTest() {
		new OAAtomFeedView();
	}

	
	@Test
	public void renderAtom() throws Exception {
		
		view.render(mv.getModel(), request, response);
		//System.out.print(response.getContentAsString());
		assertEquals("application/atom+xml", response.getContentType());
		
	}
	
}
