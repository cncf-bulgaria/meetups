# Running Unikraft unikernel on Unikraft Cloud with scale-to-zero enabled

## Create an Nginx instance with scale-to-zero
1. Watch the state of the instances
   ```bash
   watch -n 0.5 kraft cloud inst ls
   ```

1. Create a service
   ```bash
   kraft cloud svc create -n nginx 443:8080/http+tls
   kraft cloud svc get nginx
   ```

1. Create an Nginx instance with scale to zero enabled
   ```bash
   kraft cloud inst create --name nginx --memory 128 --service nginx --scale-to-zero on nginx:latest
   kraft cloud inst get nginx
   clear
   ```

1. Send a request to Nginx
   ```bash
   export NGINX_HOST=$(kraft cloud svc get nginx -o json | jq -r '.[0].fqdn')
   curl https://$NGINX_HOST
   ```
   Note: Observe the state of the instance.  
   Every time when you send a request, it should change to `running` and then back to `standby`.  
   You can observe such change in the state only if you have a low latency connection (preferably via cable).  

## Cleanup
   ```bash
   kraft cloud inst rm --all
   kraft cloud svc rm --all
   ```
