<%@include file="paypalfunctions.jsp" %>

<%
String PaymentOption = request.getParameter("CreditCardType"); //"Visa";
 if ((PaymentOption.equalsIgnoreCase("Visa"))||(PaymentOption.equalsIgnoreCase("MasterCard"))||(PaymentOption.equalsIgnoreCase("Discover"))||(PaymentOption.equalsIgnoreCase("American Express")))
 {

	String paymentAmount = "12.00";//"105.87";//(String)session.getAttribute("Payment_Amount");

	//String paymentType = "Authorization";
        String paymentType = "Sale";
        String creditCardType = request.getParameter("CreditCardType");//"Visa";
	String creditCardNumber	= request.getParameter("CreditCardNumber"); //"4716968596999172";
	String expDate = "042013"; //request.getParameter("122014"); //"122012";//
	String cvv2 = request.getParameter("CSC"); //"111";//
	String firstName = request.getParameter("FirstName");//"AAA";//
	String lastName = request.getParameter("LastName"); //"BBB";//
	String street = request.getParameter("addressline1"); //"111111";//
	String city = request.getParameter("City");	//"Omaha";//
	String state = request.getParameter("state");//"NE";//
	String zip = request.getParameter("Zipcode"); //"68182";//
	String countryCode = "US"; //request.getParameter("US"); //"US";//
	String currencyCode = "USD"; // request.getParameter("USD");	//"USD";//
	String IPAddress = request.getRemoteAddr();
	
	HashMap nvp = DirectPayment ( paymentType, paymentAmount, creditCardType, creditCardNumber, expDate, cvv2, firstName, lastName, street, city, state, zip, countryCode, currencyCode, IPAddress ); 
        String strAck = nvp.get("ACK").toString();
        out.println("Thank you for your Order!!!"+"<br/>Acknowledgement:"+nvp+"<br/><br/>");
        %>
        <a href="http://localhost:7101/WPP_TestApp-ViewController-context-root/CheckoutPage.html">Continue Shopping</a>
        <%
        
        /*if(strAck ==null || strAck.equalsIgnoreCase("Success") || strAck.equalsIgnoreCase("SuccessWithWarning") )
	{
		// Display a user friendly Error on the page using any of the following error information returned by PayPal
		String ErrorCode = nvp.get("L_ERRORCODE0").toString();
		String ErrorShortMsg = nvp.get("L_SHORTMESSAGE0").toString();
		String ErrorLongMsg = nvp.get("L_LONGMESSAGE0").toString();
		String ErrorSeverityCode = nvp.get("L_SEVERITYCODE0").toString();
	}*/
  }
    
%>