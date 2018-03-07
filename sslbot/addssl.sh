#/usr/bin/bash
if [[ $1 != '' ]]; then
  sed "s/DOMAIN/$1/g" /etc/nginx/conf.d/ssl.template > /etc/nginx/conf.d/$1.conf
  if [ $? -eq 0 ]; then
    certbot-auto --nginx --no-redirect --staple-ocsp --keep-until-expiring -d $1
  fi
else
  echo "Usage: $0 DOMAIN"
fi

