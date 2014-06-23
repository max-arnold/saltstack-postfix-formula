{% from "postfix/map.jinja" import postfix with context %}
{% from "postfix/context.jinja" import mynetworks,mailname,myhostname,inet_interfaces with context %}
{% set relayhost = pillar.get('postfix:relayhost') %}
{% set relayuser = pillar.get('postfix:relayuser') %}
{% set relaypass = pillar.get('postfix:relaypass') %}
{% set canonical = pillar.get('postfix:canonical') %}

include:
  - postfix

extend:
  postfix:
    debconf.set:
      - data:
          'postfix/main_mailer_type': {'type': 'select', 'value': 'Satellite system'}
          'postfix/mailname': {'type': 'string', 'value': '{{ myhostname }}'}
          'postfix/destinations': {'type': 'string', 'value': 'localhost.localdomain, localhost'}
          'postfix/mynetworks': {'type': 'string', 'value': '{{ mynetworks }}'}
          'postfix/relayhost': {'type': 'string', 'value': '{{ relayhost }}'}
  /etc/postfix/main.cf:
    file.managed:
      - source: salt://postfix/satellite/files/main.cf
      - template: jinja
      - context:
        myhostname: {{ myhostname }}
        mynetworks: {{ mynetworks }}
        inet_interfaces: {{ inet_interfaces }}
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
