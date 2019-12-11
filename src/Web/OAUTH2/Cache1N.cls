Class Web.OAUTH2.Cache1N Extends %CSP.Page
{

Parameter OAUTH2CLIENTREDIRECTURI = "https://localhost/csp/myclient/Web.OAUTH2.Cache2N.cls";

Parameter OAUTH2APPNAME = "Client";

ClassMethod OnPage() As %Status
{
  &html<<html>
<head>
  <style>
  
  .portalLogo {
    color: rgb(53,107,141);
    position: relative;
    font-weight: bold;
    font-size: 12pt;
    top: 0px;
    right: 0px;
    border: 2px solid rgb(53,107,141);
    padding: 2px;
    padding-left: 5px;
    padding-right: 5px;
    border-radius: 4px;
    background: #E0E0F0;
}

.portalLogoBox {
    position: static;
    padding: 10px;
    padding-bottom: 4px;
    padding-right: 30px;
    text-align: center;
}

.portalLogoSub {
    position: relative;
    color: #808080;
    font-size: 8pt;
    top: 3px;
    right: 0px;
}
  
  </style>
  
</head>
<body>
  <h1>Authenticating and Authorizing against Cache&acute; OAuth2 provider</h1>
  <p>This page demo shows how to call Cache&acute; API functions using OAuth2 authorization.
  <p>We are going to call Cache&acute; authentication and authorization server to grant our application access to data stored at another
  Cache&acute; server.
 >
  
  // Get the url for authorization endpoint with appropriate redirect and scopes.
  // The returned url is used in the button below.
  
  // DK: use 'dankut' account to authenticate!
  set scope="openid profile scope1 scope2"
  set url=##class(%SYS.OAuth2.Authorization).GetAuthorizationCodeEndpoint(
    ..#OAUTH2APPNAME,
    scope,
    ..#OAUTH2CLIENTREDIRECTURI,
    .properties,
    .isAuthorized,
    .sc)
  if $$$ISERR(sc) {
    write "GetAuthorizationCodeEndpoint Error="
    write ..EscapeHTML($system.Status.GetErrorText(sc))_"<br>",!
  } 
  
  &html<
  <div class="portalLogoBox"><a class="portalLogo" href="#(url)#">Authorize for <b>ISC</b></a></div>
  </body></html>>
  Quit $$$OK
}

ClassMethod OnPreHTTP() As %Boolean [ ServerOnly = 1 ]
{
  #dim %response as %CSP.Response
  set scope="openid profile scope1 scope2"
  if ##class(%SYS.OAuth2.AccessToken).IsAuthorized(..#OAUTH2APPNAME,,scope,.accessToken,.idtoken,.responseProperties,.error) {
    set %response.ServerSideRedirect="Web.OAUTH2.Cache2N.cls"
  }
  quit 1
}

}
