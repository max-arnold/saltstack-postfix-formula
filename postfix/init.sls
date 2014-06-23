{% from "postfix/map.jinja" import postfix with context %}
{% from "postfix/context.jinja" import mynetworks,mailname,myhostname,inet_interfaces with context %}

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
    - source: salt://postfix/files/main.cf
    - template: jinja
    - context:
      myhostname: {{ myhostname }}
      mynetworks: {{ mynetworks }}
      inet_interfaces: {{ inet_interfaces }}

/etc/postfix/master.cf:
  file.managed:
    - source: salt://postfix/files/master.cf
    - template: jinja

/etc/postfix/maps:
  file.directory:
    - user: root
    - group: root
    - mode: 755
