Using custom locales
====================

Personalized translations go into the `config/custom_locales/` directory.
Custom locales can be identified by the rails environment, schema name in a
multitenancy setup or domain name until the first dot (e.g env1.coop.br for the
example below).

Currently, the only filename prefix for the localization file which is
processed is "environment". For instance, a POT file would be called
"environment.pot".

The structure of an environment named env1 with custom translations for both
Portuguese and Spanish and an environment named env2 with custom Russian
translation would be:

    config/
      custom_locales/
        env1/
          environment.pot
          pt/
            environment.po
          es/
            environment.po
        env2/
          environment.pot
          ru/
            environment.po

