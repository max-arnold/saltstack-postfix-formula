{% from "postfix/map.jinja" import postfix with context %}
{% set mynetworks = pillar.get('postfix:mynetworks', '127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128') %}
{% set mailname = pillar.get('postfix:mailname', grains['fqdn']) %}

postfix:
  debconf.set:
    - data:
        'postfix/main_mailer_type': {'type': 'select', 'value': 'No configuration'}
        'postfix/mailname': {'type': 'string', 'value': '{{ mailname }}'}
        'postfix/destinations': {'type': 'string', 'value': 'localhost.localdomain, localhost'}
        'postfix/mynetworks': {'type': 'string', 'value': '{{ mynetworks }}'}
  pkg.installed:
    - require:
      - debconf: postfix
    - pkgs:
       - postfix
       - postfix-pcre
  service.running:
    - watch:
      - pkg: postfix
