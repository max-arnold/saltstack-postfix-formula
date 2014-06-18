{% from "postfix/map.jinja" import postfix with context %}
{% set mynetworks = pillar.get('postfix:mynetworks', '127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128') %}
{% set mailname = pillar.get('postfix:mailname', grains['fqdn']) %}
{% set myhostname = pillar.get('postfix:myhostname', grains['fqdn']) %}
{% set inet_interfaces = pillar.get('postfix:inet_interfaces', 'loopback-only') %}

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
    - require_in:
      - file: /etc/mailname
      - file: /etc/postfix/maps
      - file: /etc/postfix/main.cf
      - file: /etc/postfix/master.cf
  service.running:
    - watch:
      - pkg: postfix
      - file: /etc/postfix/main.cf
      - file: /etc/postfix/master.cf

/etc/mailname:
  file.managed:
    - source: salt://postfix/files/mailname
    - template: jinja
    - context:
      mailname: {{ mailname }}

/etc/postfix/main.cf:
  file.managed:
    - source: salt://postfix/files/{{ postfix.conf_prefix }}/main.cf
    - template: jinja
    - context:
      myhostname: {{ myhostname }}
      mynetworks: {{ mynetworks }}
      inet_interfaces: {{ inet_interfaces }}

/etc/postfix/master.cf:
  file.managed:
    - source: salt://postfix/files/{{ postfix.conf_prefix }}/master.cf
    - template: jinja

/etc/postfix/maps:
  file.directory:
    - user: root
    - group: root
    - mode: 755
