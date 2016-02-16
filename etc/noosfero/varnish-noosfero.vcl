vcl 4.0;

sub vcl_recv {
  if (req.method == "GET" || req.method == "HEAD") {
    if (req.http.Cookie) {
      # We only care about the "_noosfero_.*" cookies, used by Noosfero
      if (req.http.Cookie !~ "_noosfero_.*" ) {
        # strip all cookies
        unset req.http.Cookie;
      }
    }
  }
}

sub vcl_deliver {
  # Force clients to aways hit the server again for HTML pages
  if (resp.http.Content-Type ~ "^text/html") {
    set resp.http.Cache-Control = "no-cache";
  }
}

sub vcl_backend_error {
    set beresp.http.Content-Type = "text/html; charset=utf-8";

    synthetic({"
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
  <head>
  <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
  <meta http-equiv="refresh" content="60"/>
  <title>Technical problems</title>
  <link rel="stylesheet" type="text/css" href="/designs/themes/default/errors.css"/>
  <link rel="shortcut icon" href='/designs/themes/default/favicon.ico' type="image/x-icon" />
  <script type='text/javascript' src='https://ajax.googleapis.com/ajax/libs/prototype/1.7.0.0/prototype.js'></script>
  <script type='text/javascript'>
  function display_error_message(language) {
    if (!language) {
      var language = ((navigator.language) ? navigator.language : navigator.userLanguage).replace('-', '_');
    }
    element = $(language);
    if (!element) {
      element = $(language.replace(/_.*$/, ''));
    }
    if (!element) {
      element = $('en');
    }
    $$('.message').each(function(item) { item.hide() });
    element.getElementsBySelector('h1').each(function(title) { document.title = title.innerHTML; });
    element.show();
  }
  </script>
</head>
<body onload='display_error_message()'>
  <div id='wrap'>
    <div id='header'>
      <div id='logo'>&nbsp;</div>
      <div id='details'><b>"} + beresp.status + "</b> - " + beresp.reason + {"</div>
    </div>

    <div id='de' style='display: none' class='message'>
      <h1>Kurzzeitiges Systemproblem</h1>
      <p>
      Unser technisches Team arbeitet gerade daran, bitte probieren Sie es nachher erneut. Wir entschuldigen uns f&uuml;r die Unannehmlichkeiten.
      </p>
      <ul>
        <li><a href='javascript: history.back()'>Zur&uuml;ck</a></li>
        <li><a href='/'>Gehe zur Homepage</a></li>
      </ul>
    </div>

    <div id='en' style='display: none' class='message'>
      <h1>Temporary system problem</h1>
      <p>
      Our technical team is working on it, please try again later. Sorry for the inconvenience.
      </p>
      <ul>
        <li><a href='javascript: history.back()'>Go back</a></li>
        <li><a href='/'>Go to the site home page</a></li>
      </ul>
    </div>

    <div id='es' style='display: none' class='message'>
      <h1>Temporary system problem</h1>
      <p>
      Our technical team is working on it, please try again later. Sorry for the inconvenience.
      </p>
      <ul>
        <li><a href='javascript: history.back()'>Go back</a></li>
        <li><a href='/'>Go to the site home page</a></li>
      </ul>
    </div>

    <div id='fr' style='display: none' class='message'>
      <h1>Probl&egrave;me temporaire du syst&egrave;me.</h1>
      <p>
      Notre &eacute;quipe technique est en train d'y travailler. Merci de r&eacute;essayer plus tard. Nous sommes d&eacute;sol&eacute;s de la g&ecirc;ne occasionn&eacute;e.
      </p>
      <ul>
        <li><a href='javascript: history.back()'>Retour</a></li>
        <li><a href='/'>Aller &agrave; la page d'accueil du site</a></li>
      </ul>
    </div>

    <div id='hy' style='display: none' class='message'>
      <h1>Temporary system problem</h1>
      <p>
      Our technical team is working on it, please try again later. Sorry for the inconvenience.
      </p>
      <ul>
        <li><a href='javascript: history.back()'>&#x054e;&#x0565;&#x0580;&#x0561;&#x0564;&#x0561;&#x057c;&#x0576;&#x0561;&#x056c;</a></li>
        <li><a href='/'>Go to the site home page</a></li>
      </ul>
    </div>

    <div id='pt' style='display: none' class='message'>
      <h1>Problema tempor&aacute;rio no sistema</h1>
      <p>
      Nossa equipe t&eacute;cnica est&aacute; trabalhando nele, por favor tente mais tarde. Perdoe o incoveniente.
      </p>
      <ul>
        <li><a href='javascript: history.back()'>Voltar</a></li>
        <li><a href='/'>Ir para a p&aacute;gina inicial do site.</a></li>
      </ul>
    </div>

    <div id='ru' style='display: none' class='message'>
      <h1>&#x0412;&#x0440;&#x0435;&#x043c;&#x0435;&#x043d;&#x043d;&#x0430;&#x044f; &#x043e;&#x0448;&#x0438;&#x0431;&#x043a;&#x0430; &#x0441;&#x0438;&#x0441;&#x0442;&#x0435;&#x043c;&#x044b;</h1>
      <p>
      &#x0422;&#x0435;&#x0445;&#x043d;&#x0438;&#x043a;&#x0438; &#x0443;&#x0436;&#x0435; &#x0440;&#x0430;&#x0431;&#x043e;&#x0442;&#x0430;&#x044e;&#x0442; &#x043d;&#x0430;&#x0434; &#x043f;&#x0440;&#x043e;&#x0431;&#x043b;&#x0435;&#x043c;&#x043e;&#x0439;, &#x043f;&#x043e;&#x0436;&#x0430;&#x043b;&#x0443;&#x0439;&#x0441;&#x0442;&#x0430;, &#x043f;&#x043e;&#x043f;&#x0440;&#x043e;&#x0431;&#x0443;&#x0439;&#x0442;&#x0435; &#x043f;&#x043e;&#x0437;&#x0436;&#x0435;.
      </p>
      <ul>
        <li><a href='javascript:history.back()'>&#x041d;&#x0430;&#x0437;&#x0430;&#x0434;</a></li>
        <li><a href='/'>&#x041f;&#x0435;&#x0440;&#x0435;&#x0439;&#x0442;&#x0438; &#x043d;&#x0430; &#x0434;&#x043e;&#x043c;&#x0430;&#x0448;&#x043d;&#x044e;&#x044e; &#x0441;&#x0442;&#x0440;&#x0430;&#x043d;&#x0438;&#x0446;&#x0443; &#x0441;&#x0430;&#x0439;&#x0442;&#x0430;</a></li>
      </ul>
    </div>

    <div id='languages'>
        <a href="javascript: display_error_message('de')">Deutsch</a>
        <a href="javascript: display_error_message('en')">English</a>
        <a href="javascript: display_error_message('es')">Espa&ntilde;ol</a>
        <a href="javascript: display_error_message('fr')">Fran&ccedil;ais</a>
        <a href="javascript: display_error_message('hy')">&#x0570;&#x0561;&#x0575;&#x0565;&#x0580;&#x0565;&#x0576; &#x056c;&#x0565;&#x0566;&#x0578;&#x0582;</a>
        <a href="javascript: display_error_message('pt')">Portugu&ecirc;s</a>
        <a href="javascript: display_error_message('ru')">&#x0440;&#x0443;&#x0441;&#x0441;&#x043a;&#x0438;&#x0439; &#x044f;&#x0437;&#x044b;&#x043a;</a>
    </div>

  </div>
</body>
</html>
     "});
    return(deliver);
}
