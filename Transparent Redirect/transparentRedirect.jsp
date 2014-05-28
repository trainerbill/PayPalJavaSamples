<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
"http://www.w3.org/TR/html4/loose.dtd">
<%@ page contentType="text/html;charset=windows-1252"%>
<html>
	 <head>
		<meta http-equiv="Content-Type" content="text/html; charset=windows-1252"/>
		<title>Transparent Redirect</title>
	  <%@include file="paypalfunctions.jsp" %>
	  <%

		/*
		'-------------------------------------------
		' The paymentAmount is the total value of 
		' the shopping cart, that was set 
		' earlier in a session variable 
		' by the shopping cart page
		'-------------------------------------------
		*/

		String paymentAmount = "20.00";//(String) session.getAttribute("Payment_Amount");
		String currencyCodeType = "USD";
		session.setAttribute("currencyCodeType", currencyCodeType);
		String paymentType = "Authorization";//"Authorization";//
		session.setAttribute("paymentType", paymentType);
		String firstName = "Pavana"; //request.getParameter("firstname");
		String lastName = "D"; //request.getParameter("lastname");
		String street = "123 Main Street"; //request.getParameter("street");
		String city = "Omaha"; //request.getParameter("city");
		String state = "NE"; //request.getParameter("state");
		String zip = "68128"; //request.getParameter("zip");
		String countryCode = "US"; //request.getParameter("country");
		String orderdescription = "test order"; //request.getParameter("desc");
		HashMap nvp = getSecureTokenTR (paymentType, paymentAmount, firstName, lastName, street, city, state, zip, countryCode, currencyCodeType, orderdescription);// ccnumber, expDate, cvv);
		String securetoken = nvp.get("SECURETOKEN").toString();
		String securetokenid = nvp.get("SECURETOKENID").toString();
		
	%>


 </head>
 <body>

        <form method='post' action='https://payflowlink.paypal.com/'>
            <input type='hidden' name='SECURETOKEN' value="<%= securetoken %>"/>
            <input type='hidden' name='SECURETOKENID' value="<%= securetokenid %>" />
            <input type='hidden' name='MODE' value='test' />
            <input type="text" name = 'ACCT' value='4843332174803197'/>
            <input type="text" name = 'EXPDATE' value='1215'/>
            <input type="text" name = 'CVV2' value='123'/>            
            <input type="hidden" name= 'USER1' value='custom 1'/>
            <input type="hidden" name= 'USER2' value='custom 2'/>
            <input type='image' name='submit' id="submitBtn" src='https://www.paypal.com/en_US/i/btn/btn_dg_pay_w_paypal.gif' border='0' align='top' alt='Check out with PayPal'/>
        </form>

	 </body>
</html>