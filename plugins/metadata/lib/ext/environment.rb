require_dependency 'environment'

class Environment

  Metadata = {
    'og:site_name' => proc{ |e, c| e.name },
    'og:description' => proc{ |e, c| e.name },
    'og:url' => proc{ |e, c| e.top_url },
    'og:locale:locale' => proc{ |e, c| e.default_language },
    'og:locale:alternate' => proc{ |e, c| e.languages - [e.default_language] }
  }

end
