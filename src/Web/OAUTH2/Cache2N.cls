Class Web.OAUTH2.Cache2N Extends %CSP.Page
{

Parameter OAUTH2APPNAME = "Client";

Parameter OAUTH2ROOT = "https://localhost/api";

Parameter SSLCONFIG = "SSL";

ClassMethod OnPage() As %Status
{
    &html<<html>
<head>
</head>

<style>
body { font-family: verdana; }

h4 { color:#2080E0 ;}
</style>

<body>>
    
    // Check if we have an access token from oauth2 server
    set isAuthorized=##class(%SYS.OAuth2.AccessToken).IsAuthorized(..#OAUTH2APPNAME,,"scope1 scope2",.accessToken,.idtoken,.responseProperties,.error)
    
    // Continue with further checks if an access token exists.
    // Below are all possible tests and may not be needed in all cases.
    // The JSON object which is returned for each test is just displayed.
    if isAuthorized {
        write "<h3>Authorized!</h3>",!
        
        
        // Validate and get the details from the access token, if it is a JWT.
        set valid=##class(%SYS.OAuth2.Validation).ValidateJWT(..#OAUTH2APPNAME,accessToken,"scope1 scope2",,.jsonObject,.securityParameters,.sc)
        if $$$ISOK(sc) {
            if valid {
                write "Valid JWT"_"<br>",!    
            } else {
                write "Invalid JWT"_"<br>",!    
            }
            write "Access token="
            do jsonObject.%ToJSON()
            write "<br>",!
        } else {
            write "JWT Error="_..EscapeHTML($system.Status.GetErrorText(sc))_"<br>",!    
        }
        write "<br>",!

        // Call the introspection endpoint and display result -- see RFC 7662.
        set sc=##class(%SYS.OAuth2.AccessToken).GetIntrospection(..#OAUTH2APPNAME,accessToken,.jsonObject)
        if $$$ISOK(sc) {
            write "Introspection="
            do jsonObject.%ToJSON()
            write "<br>",!
        } else {
            write "Introspection Error="_..EscapeHTML($system.Status.GetErrorText(sc))_"<br>",!    
        }
        write "<br>",!
        
        if idtoken'="" {
            // Validate and display the IDToken -- see OpenID Connect Core specification.
            set valid=##class(%SYS.OAuth2.Validation).ValidateIDToken(
                ..#OAUTH2APPNAME,
                idtoken,
                accessToken,,,
                .jsonObject,
                .securityParameters,
                .sc)
            if $$$ISOK(sc) {
                if valid {
                    write "Valid IDToken"_"<br>",!    
                } else {
                    write "Invalid IDToken"_"<br>",!    
                }
                write "IDToken="
                do jsonObject.%ToJSON()
                write "<br>",!
            } else {
                write "IDToken Error="_..EscapeHTML($system.Status.GetErrorText(sc))_"<br>",!    
            }
        } else {
            write "No IDToken returned"_"<br>",!
        }
        write "<br>",!
    
        // not needed for the application logic, but provides information about user that we can pass to Delegated authentication
    
        // Call the userinfo endpoint and display the result -- see OpenID Connect Core specification.
        set sc=##class(%SYS.OAuth2.AccessToken).GetUserinfo(
            ..#OAUTH2APPNAME,
            accessToken,,
            .jsonObject)
        if $$$ISOK(sc) {
            write "Userinfo="
            do jsonObject.%ToJSON()
            write "<br>",!
        } else {
            write "Userinfo Error="_..EscapeHTML($system.Status.GetErrorText(sc))_"<br>",!    
        }
        write "<p>",!

        /***************************************************
        *                                                  *
        *   Call the resource server and display result.   *
        *                                                  *
        ***************************************************/
                
        // option 1 - resource server - by definition - trusts data coming from authorization server,
        //     so it serves data to whoever is asking
        //  as long as access token passed to resource server is valid
        
        // option 2 - alternatively, you can use delegated authentication (OpenID Connect) 
        //  and call into another CSP application (with delegated authentication protection)
        //  - that's what we do here in this demo
        
        
        write "<h4>Call resource server (delegated auth)","</h4>",!
        set httpRequest=##class(%Net.HttpRequest).%New()
        // AddAccessToken adds the current access token to the request.
        set sc=##class(%SYS.OAuth2.AccessToken).AddAccessToken(
            httpRequest,,
            ..#SSLCONFIG,
            ..#OAUTH2APPNAME)
        if $$$ISOK(sc) {
           set sc=httpRequest.Get(..#OAUTH2ROOT_"/close/Web.OAUTH2.demoResourceWithTokenAuth.cls")
        }
        if $$$ISOK(sc) {
            set body=httpRequest.HttpResponse.Data
            if $isobject(body) {
                do body.Rewind()
                set body=body.Read()
            }
            write body,"<br>",!
        }
        if $$$ISERR(sc) {
            write "Resource Server Error="_..EscapeHTML($system.Status.GetErrorText(sc))_"<br>",!    
        }
        write "<br>",!
    
        write "<h4>Call resource server - no auth, just token validity check","</h4>",!
        set httpRequest=##class(%Net.HttpRequest).%New()
        // AddAccessToken adds the current access token to the request.
        set sc=##class(%SYS.OAuth2.AccessToken).AddAccessToken(
            httpRequest,,
            ..#SSLCONFIG,
            ..#OAUTH2APPNAME)
        if $$$ISOK(sc) {
            set sc=httpRequest.Get(..#OAUTH2ROOT_"/open/Web.OAUTH2.demoResourceWithTokenCheck.cls")
        }
        if $$$ISOK(sc) {
            set body=httpRequest.HttpResponse.Data
            if $isobject(body) {
                do body.Rewind()
                set body=body.Read()
            }
            write body,"<br>",!
        }
        if $$$ISERR(sc) {
            write "Resource Server Error="_..EscapeHTML($system.Status.GetErrorText(sc))_"<br>",!    
        }
        write "<br>",!
    } else {
        write "Not Authorized!<p>",!
        write "<a href='Web.OAUTH2.Cache1N.cls'>Authorize me</a>"
    }    
    &html<</body></html>>
    Quit $$$OK
}

}
