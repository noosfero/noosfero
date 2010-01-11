STYLESHEETS = \
  button.css\
  layout.css\
  blocks.css\
  search-results.css\
  article.css\
  controllers.css

release:
	cat $(STYLESHEETS) > style.css

development:
	for item in $(STYLESHEETS); do echo $$item; done | sed -e 's/.*/@import url(&);/' > style.css

clean:
	rm -f *~ */*~
