#!/bin/sh

certbot-auto renew --post-hook="service nginx reload"
