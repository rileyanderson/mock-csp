# Mock CSP

## Android issue
With mobiles new android release users are getting stuck on the client side redirect back to the mobile app:
`Navigation is blocked:`

I believe Navigation is getting blocked because we are submitting a form with Javascript. There are other ways we
can do this redirect that appear to work - window.href, meta refresh.

## Potential Solution
- Simulating the redirect by putting the address directly in the address bar will not work e.g
  - I have a server - localhost:4000
  - I have an endpoint, localhost:4000/redirect, that renders html with javascript redirects to the mobile app - myapp://callback
  - I open chrome on android
  - Go to localhost:4000/redirect
  - I will not be redirected to the app

- A user must initiate that action in order to be redirected back to the app
  - It appears that the user submitting the form from the CSP is enough
    - Submit CSP form
    - CSP redirects to SIS
    - SiS renders HTML with js/meta redirect to mobile app
    - Mobile app opens

## Try it out
### [Mock CSP](https://github.com/rileyanderson/mock-csp)
https://mock-csp.onrender.com/
This is a mock credential service provider (CSP) that mocks form submit portion of the Sign-In Service (SiS) OAUTH flow.
Form submit buttons exist for differnt types of client side redirects. These make calls to a mock sign-in service application
- JS Form Submit - currently implemented on SiS
  ```html
  <!DOCTYPE html>
  <html lang="en">
  <head>
    <meta charset="utf-8">
    <title>Form Submit</title>
  </head>
  <body>
    <form action="vamobile://login-success" method="get" id="oauth-form">
      <input type="hidden" name="code" value="523513fdvq34gberfq243g" />
      <input type="hidden" name="type" value="logingov" />
      <noscript>
        <div>
          <input type="submit" value="Continue"/>
        </div>
      </noscript>
    </form>

    <script nonce="CSP_NONCE" >
      (function() {
        document.getElementById("oauth-form").submit();
      })();
    </script>
  </body>
  </html>
  ```

- JS Window Replace
  ``` html
  <!DOCTYPE html>
  <html>
    <head>
      <script>
          function redirect() {
              window.location.href = "vamobile://login-success";
          }
      </script>
    </head>
    <body onload="redirect()"></body>
  </html>
  ```

- Meta Refresh
  ```html
  <!DOCTYPE html>
  <html>
    <head>
      <meta http-equiv="refresh" content="0;URL='vamobile://login-success'" />
    </head>
    <body></body>
  </html>
  ```

  ## [Mock SiS](https://github.com/rileyanderson/mock-sis)
  https://mock-sis.onrender.com
  This is an application that will render the specified html from the Mock CSP redirect

  ## Steps to reproduce
  ### Reproduce error
  - Open Chrome on Android device or emulator with VA app downloaded
  - Open Chromer dev tools - Crome on you computer - `chrome://inspect/#devices`
  - Android chrome - Navigate to https://mock-csp.onrender.com/
  - Click `Login JS Form Submit`
  - The form will submit to mock-csp server
  - mock-csp will redirect to mock-sis
  - mock-sis will render html with JS form submit
  - You will not be redirected to the app and you will see an Navigation error in the console.

  ### Potential solution - JS window replace
  - Open Chrome on Android device or emulator with VA app downloaded
  - Android chrome - Navigate to https://mock-csp.onrender.com/
  - Click `Login JS Window Replace`
  - The form will submit to mock-csp server
  - mock-csp will redirect to mock-sis
  - mock-sis will render html with JS window replaace
  - You will be redirected to the app

  ### Potential solution - Meta Refresh
  - Open Chrome on Android device or emulator with VA app downloaded
  - Android chrome - Navigate to https://mock-csp.onrender.com/
  - Click `Login Meta Refresh`
  - The form will submit to mock-csp server
  - mock-csp will redirect to mock-sis
  - mock-sis will render html with meta refresh tag
  - You will be redirected to the app

  ### Gotchas
  - If navigate to any of the mock-sis paths directly you will not be redirected to the app
    - e.g. if you try to navigate to https://mock-sis.onrender.com/callback-meta directly the app will not open.
    - it needs to be initiated through the CSP form submit
