{% from "postfix/map.jinja" import postfix with context %}
{% import "postfix/context.jinja" as ctx with context %}
{% set relayhost = salt['pillar.get']('postfix:relayhost') %}
{% set relayuser = salt['pillar.get']('postfix:relayuser') %}
{% set relaypass = salt['pillar.get']('postfix:relaypass') %}
{% set canonical = salt['pillar.get']('postfix:canonical') %}

include:
  - postfix

extend:
  postfix:
    debconf.set:
      - data:
          'postfix/main_mailer_type': {'type': 'select', 'value': 'Satellite system'}
          'postfix/mailname': {'type': 'string', 'value': '{{ ctx.myhostname }}'}
          'postfix/destinations': {'type': 'string', 'value': 'localhost.localdomain, localhost'}
          'postfix/mynetworks': {'type': 'string', 'value': '{{ ctx.mynetworks }}'}
          'postfix/relayhost': {'type': 'string', 'value': '{{ relayhost }}'}
  /etc/postfix/main.cf:
    file.managed:
      - source: salt://postfix/satellite/files/main.cf
      - template: jinja
      - context:
        myhostname: {{ ctx.myhostname }}
        mynetworks: {{ ctx.mynetworks }}
        inet_interfaces: {{ ctx.inet_interfaces }}
        smtpd_tls_cert: {{ ctx.smtpd_tls_cert }}
        smtpd_tls_key: {{ ctx.smtpd_tls_key }}
        smtpd_tls_ca: {{ ctx.smtpd_tls_ca }}
        relayhost: {{ relayhost }}

/etc/postfix/maps/sender-canonical:
  file.managed:
    - source: salt://postfix/satellite/files/sender-canonical
    - template: jinja
    - context:
      canonical: {{ canonical }}
    - require:
      - pkg: postfix
      - file: /etc/postfix/maps
    - watch_in:
        - service: postfix

/etc/postfix/sasl/passwd:
  file.managed:
    - require:
      - pkg: postfix
    - source: salt://postfix/satellite/files/sasl-passwd
    - template: jinja
    - context:
      relayhost: {{ relayhost }}
      relayuser: {{ relayuser }}
      relaypass: {{ relaypass }}
    - watch_in:
      - service: postfix
  cmd.wait:
    - name: postmap /etc/postfix/sasl/passwd
    - cwd: /
    - watch:
      - file: /etc/postfix/sasl/passwd
