<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
"http://www.w3.org/TR/html4/loose.dtd">
<%@ page contentType="text/html;charset=windows-1252"%>
<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=windows-1252"/>
    <title>OrderReview</title>
  </head>
  <body>
   <%!
  String token;
  String mytoken;
  %>
  <%
	/*==================================================================
	 PayPal Express Checkout Call
	 ===================================================================
	*/
/* 
	This step indicates whether the user was sent here by PayPal 
	if this value is null then it is part of the regular checkout flow in the cart
*/
try
{
    String str = request.getQueryString();

    StringTokenizer st=new StringTokenizer(str,"&");
    if(st.hasMoreTokens())
    {
    String tokens=st.nextToken(); //Here you will get A, sg, fall as separated tokens
    StringTokenizer st1=new StringTokenizer(tokens,"=");
        while(st.hasMoreTokens())
            {
                mytoken = st1.nextToken();
                //session.setAttribute("TOKEN", mytoken);
            }
    }

}
catch(Exception e)
{
    e.printStackTrace();
}
if (mytoken!=null)
{
    
%>
<%@include file="paypalfunctions.jsp" %>
<%
	/*
	'------------------------------------
	' Calls GetExpressCheckoutDetails
	'
	' The GetShippingDetails function is defined in PayPalFunctions.jsp
	' included at the top of this file.
	'-------------------------------------------------
	*/
	
	HashMap nvp = GetShippingDetails(mytoken,session);
	String strAck = nvp.get("RESULT").toString();
	if(strAck != null && strAck.equalsIgnoreCase("0"))
	{
		String email 			= nvp.get("EMAIL").toString(); // ' Email address of payer.
    
                String payerId 			= nvp.get("PAYERID").toString(); // ' Unique PayPal customer account identification number.
            session.setAttribute("PAYERID",payerId);
    
        	String payerStatus		= nvp.get("PAYERSTATUS").toString(); // ' Status of payer. Character length and limitations: 10 single-byte alphabetic characters.
    
                String shipToStreet		= nvp.get("SHIPTOSTREET").toString(); // ' First street address.
                String shipToCity		= nvp.get("SHIPTOCITY").toString(); // ' Name of city.
            
                String shipToState		= nvp.get("SHIPTOSTATE").toString(); // ' State or province
            
                String shipToCntryCode	= nvp.get("SHIPTOCOUNTRY").toString(); // ' Country code. 
            
                String shipToZip		= nvp.get("SHIPTOZIP").toString(); // ' U.S. Zip code or other country-specific postal code.
            
                String addressStatus 	= nvp.get("ADDRESSSTATUS").toString(); // ' Status of street address on file with PayPal   
            
		/*
		' The information that is returned by the GetExpressCheckoutDetails call should be integrated by the partner into his Order Review 
		' page		
		*/
%>
               <form action="OrderConfirmation.jsp" method="POST">
               Email : <%=email%><br/>
               Payer ID : <%=payerId%><br/>
               Payer Status : <%=payerStatus%><br/>
               
               shipToStreet : <%=shipToStreet%><br/>
               shipToCity : <%=shipToCity%><br/>
               shipToState : <%=shipToState%><br/>
               shipToCntryCode : <%=shipToCntryCode%><br/>
               shipToZip : <%=shipToZip%><br/>
               addressStatus : <%=addressStatus%><br/>
               <input type="hidden" name="mytoken" value="<%=mytoken%>">
               <input type="submit" name="Confirm Order" value="Confirm Order">
              </form>
               
<%
	}
	else
	{  
		// Display a user friendly Error on the page using any of the following error information returned by PayPal
		// See Table 4.2 and 4.3 in http://www.paypal.com/en_US/pdf/PayflowPro_Guide.pdf for a list of RESULT values (error codes)
		//Display a user friendly Error on the page using any of the following error information returned by Payflow
		String ErrorCode = strAck;
		String ErrorMsg = nvp.get("RESPMSG").toString();
	}
}
else
{
    System.out.println("my token is null");
}
		
%>
  
  </body>
</html>