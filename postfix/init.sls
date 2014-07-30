{% from "postfix/map.jinja" import postfix with context %}
{% import "postfix/context.jinja" as ctx with context %}

postfix:
  debconf.set:
    - data:
        'postfix/main_mailer_type': {'type': 'select', 'value': 'No configuration'}
        'postfix/mailname': {'type': 'string', 'value': '{{ ctx.mailname }}'}
        'postfix/destinations': {'type': 'string', 'value': 'localhost.localdomain, localhost'}
        'postfix/mynetworks': {'type': 'string', 'value': '{{ ctx.mynetworks }}'}
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
      mailname: {{ ctx.mailname }}

/etc/postfix/main.cf:
  file.managed:
    - source: salt://postfix/files/main.cf
    - template: jinja
    - context:
      myhostname: {{ ctx.myhostname }}
      mynetworks: {{ ctx.mynetworks }}
      inet_interfaces: {{ ctx.inet_interfaces }}
      smtpd_tls_cert: {{ ctx.smtpd_tls_cert }}
      smtpd_tls_key: {{ ctx.smtpd_tls_key }}

/etc/postfix/master.cf:
  file.managed:
    - source: salt://postfix/files/master.cf
    - template: jinja

/etc/postfix/maps:
  file.directory:
    - user: root
    - group: root
    - mode: 755

# TODO: manage smtpd_tls_cert and smtpd_tls_key if defined
