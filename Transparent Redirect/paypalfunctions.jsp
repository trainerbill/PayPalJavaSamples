<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
"http://www.w3.org/TR/html4/loose.dtd">
<%@ page contentType="text/html;charset=windows-1252"%>
<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=windows-1252"/>
    <title>paypalfunctions</title>
  </head>
  <body>
 

<%@ page language="java" %>
<%@ page language="java" import="java.net.URLDecoder.*" %> 
<%@ page language="java" import="java.util.*" %> 
<%@ page language="java" import="java.util.HashMap" %> 
<%@ page language="java" import="java.util.StringTokenizer.*" %> 
<%@ page language="java" import="java.io.*" %> 
<%@ page language="java" import="java.net.*" %> 
<%@ page language="java" import="javax.net.ssl.*" %> 
 
<%
	/*
	'------------------------------------
	' Payflow Credentials 
	'------------------------------------
	*/

	gv_APIUser	= "";//Enter USER field
	gv_APIPassword	= "";//Enter PWD field
	gv_APIVendor = "";//Enter VENDOR field
	gv_APIPartner = "PayPal";
	gv_Env = "pilot"; //pilot for test transactions
        
		
	if (gv_Env == "pilot")
	{
		gv_APIEndpoint = "https://pilot-payflowpro.paypal.com";
        PAYPAL_URL = "https://www.sandbox.paypal.com/cgi-bin/webscr?cmd=_express-checkout&token=";
	}
	else
	{
		gv_APIEndpoint = "https://payflowpro.paypal.com";
		PAYPAL_URL = "https://www.paypal.com/cgi-bin/webscr?cmd=_express-checkout&token=";
	} 

	String HTTPREQUEST_PROXYSETTING_SERVER = "";
	String HTTPREQUEST_PROXYSETTING_PORT = "";
	boolean USE_PROXY = false;
	
	//WinObjHttp Request proxy settings.
	gv_ProxyServer	= HTTPREQUEST_PROXYSETTING_SERVER;
	gv_ProxyServerPort = HTTPREQUEST_PROXYSETTING_PORT;
	gv_Proxy		= 2;	//'setting for proxy activation
	gv_UseProxy		= USE_PROXY;
	
%>

<%!
    String gv_APIEndpoint;
	String gv_APIUser;
	String gv_APIPassword;
	String gv_APIVendor;
	String gv_APIPartner;
	String gv_Env;
	String gv_nvpHeader;
	String gv_ProxyServer;	
	String gv_ProxyServerPort; 
	int gv_Proxy;
	boolean gv_UseProxy;
	String PAYPAL_URL;
	String Env;
        String sessionuuid;

		
	/* ********************************************************************************
	  * httpcall: Function to perform the Payflow call
	  * 	@nvpStr is nvp string.
	  * returns a NVP string containing the response from the server.
	******************************************************************************** */
	public HashMap httpcall( String nvpStr, String unique_id )
	{

		String agent = "Mozilla/4.0";
		String respText = "";
		HashMap nvp = null;

		String encodedData = "PWD=" + gv_APIPassword + "&USER=" + gv_APIUser + "&VENDOR=" + gv_APIVendor + "&PARTNER=" + gv_APIPartner + nvpStr;

		try 
		{
			URL postURL = new URL( gv_APIEndpoint );
			HttpURLConnection conn = (HttpURLConnection)postURL.openConnection();

			// Set connection parameters. We need to perform input and output, 
	        // so set both as true. 
			conn.setDoInput (true);
			conn.setDoOutput (true);

			// Set the content type we are POSTing.
			conn.setRequestProperty("Content-Type", "text/namevalue");
			conn.setRequestProperty("User-Agent", agent );

			conn.setRequestProperty("Content-Length", String.valueOf(encodedData.length()));
			conn.setRequestMethod("POST");
			conn.setRequestProperty("PAYPAL-NVP","Y");

			// set the host header
			if (gv_Env == "pilot") 
			{
				conn.setRequestProperty("Host", "pilot-payflowpro.paypal.com");
			}
			else
			{
				conn.setRequestProperty("Host", "payflowpro.paypal.com");
			}

			conn.setRequestProperty("X-VPS-CLIENT-TIMEOUT", "90");
			conn.setRequestProperty("X-VPS-REQUEST-ID", unique_id);
                        
				
	        // get the output stream to POST to. 
			DataOutputStream output = new DataOutputStream(conn.getOutputStream());
                        
			output.writeBytes( encodedData );
			output.flush();
	        output.close();
			
			// Read input from the input stream.
			DataInputStream  in = new DataInputStream(conn.getInputStream()); 
	    	int rc = conn.getResponseCode();
			if ( rc != -1)
			{
				BufferedReader is = new BufferedReader(new InputStreamReader( conn.getInputStream()));
				String _line = null;
				while(((_line = is.readLine()) !=null))
				{
					respText = respText + _line;
				}			
				nvp = deformatNVP( respText );
			}
			return nvp;
		}
		catch( IOException e )
		{
			// handle the error here
			return null;
		}
                
	}
		
	public HashMap getSecureTokenTR(String paymentType, String paymentAmount, String firstName, String lastName, String street, String city, String state, String zip, String countryCode, String currencyCode, String orderdescription)
	{
        String nvpstr = "&TENDER=C";
		if (paymentType.equalsIgnoreCase("Sale"))
		{
			nvpstr = nvpstr + "&TRXTYPE=S";
		}
		else if (paymentType.equalsIgnoreCase("Authorization"))
		{
			nvpstr = nvpstr + "&TRXTYPE=A";
		}
		else /* default to sale */
		{
			nvpstr = nvpstr + "&TRXTYPE=S";
		}

	    /* requires at least Java 5 */
		UUID uid = UUID.randomUUID();
        UUID uid_securetokenid = UUID.randomUUID();
		nvpstr = nvpstr + "&AMT="+ paymentAmount + "&CURRENCY=" + currencyCode;
		nvpstr = nvpstr + "&BILLTOFIRSTNAME=" + firstName +"&BILLTOLASTNAME=" + firstName + "&BILLTOSTREET=" + street + "&BILLTOCITY=" + city;
		nvpstr = nvpstr + "&BILLTOSTATE=" + state + "&BILLTOZIP=" + zip + "&BILLTOCOUNTRY=" + countryCode;
		nvpstr = nvpstr + "&INVNUM=" + uid.toString() + "&ORDERDESC=" + orderdescription;
        nvpstr = nvpstr + "&Email=pavana@testing.com&SHIPTOFIRSTNAME="+firstName+"&SHIPTOLASTNAME="+firstName+"&SHIPTOSTREET="+ street+"&SHIPTOCITY="+ city+"&SHIPTOSTATE="+ state;
        nvpstr = nvpstr + "&SHIPTOZIP="+ zip+"&SHIPTOCOUNTRY="+countryCode;
		nvpstr = nvpstr + "&SILENTTRAN=TRUE&CREATESECURETOKEN=Y&MODE=TEST&RETURNURL=http://127.0.0.1:7101/PayFlow-PayFlowEC-context-root/newfinalpage.jsp&CANCELURL=http://127.0.0.1:7101/PayFlow-PayFlowEC-context-root/newfinalpage.jsp&SECURETOKENID="+uid_securetokenid + "&SILENTPOSTURL=http://127.0.0.1:7101/PayFlow-PayFlowEC-context-root/newfinalpage.jsp&ERRORURL=http://127.0.0.1:7101/PayFlow-PayFlowEC-context-root/error.jsp";
		/*
		' Transaction results (especially values for declines and error conditions) returned by each PayPal-supported
		' processor vary in detail level and in format. The Payflow Verbosity parameter enables you to control the kind
		' and level of information you want returned. 
		' By default, Verbosity is set to LOW. A LOW setting causes PayPal to normalize the transaction result values. 
		' Normalizing the values limits them to a standardized set of values and simplifies the process of integrating 
		' the Payflow SDK.
		' By setting Verbosity to MEDIUM, you can view the processor’s raw response values. This setting is more “verbose”
		' than the LOW setting in that it returns more detailed, processor-specific information. 
		' Review the chapter in the Developer's Guides regarding VERBOSITY and the INQUIRY function for more details.
		' Set the transaction verbosity to MEDIUM.
		*/
		nvpstr = nvpstr + "&VERBOSITY=HIGH";

		/*
		'-------------------------------------------------------------------------------------------
		' Make the call to Payflow to finalize payment
		' If an error occured, show the resulting errors
		'-------------------------------------------------------------------------------------------
		*/
                
		HashMap nvp = httpcall(nvpstr,uid.toString());
		
		return nvp;
	}
        
       
%>

  
  </body>
</html>