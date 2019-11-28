Class Web.OAUTH2.demoResourceWithTokenCheck Extends %CSP.Page
{

ClassMethod OnPage() As %Status
{
    set accessToken=##class(%SYS.OAuth2.AccessToken).GetAccessTokenFromRequest(.sc)
    if $$$ISOK(sc) {
        set sc=##class(%SYS.OAuth2.AccessToken).GetIntrospection("Client",accessToken,.jsonObject)
        if $$$ISOK(sc) {        
            // optionally validate against fields in jsonObject
            
            w "<p><h3>Hello from Cach&eacute; server: <i>/api/open/Web.OAUTH2.demoResourceWithTokenCheck.cls</i> application!</h3>"
            w "<p>running code as <b>$username = "_$username_"</b> with following <b>$roles = "_$roles_"</b> at node <b>"_$p($zu(86),"*",2)_"</b>."
        }
    } else {
        w "<h3>NOT AUTHORIZED!</h3>"    
        w "<pre>"
        w
        i $d(%objlasterror) d $system.OBJ.DisplayError()
        w "</pre>"
    }
    Quit $$$OK
}

}
