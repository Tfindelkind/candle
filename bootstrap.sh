for nodeip in $(kubectl get nodes -o json | jq -r '.items[] | .status .addresses[] | select(.type=="InternalIP") | .address')
do
	echo "Deleting registry to simulate dark site on $nodeip"
	sshpass -p "nutanix/4u" ssh root@$nodeip docker rmi registry
	echo "Upload registry.tar to $nodeip"
	sshpass -p "nutanix/4u" scp ./registry.tar root@$nodeip:/root/registry.tar
	echo "docker load registry to $nodeip"
	sshpass -p "nutanix/4u" ssh root@$nodeip docker load -i registry.tar
	echo ""
	sleep 2
done

echo "Deploy private registry on Karbon"
kubectl delete -f registry.yaml
kubectl create -f registry.yaml
echo ""
sleep 2

echo "Push nginx to private registry"
sleep 10
docker load -i nginx.tar
docker tag nginx 10.42.94.112:30500/nginx
docker push 10.42.94.112:30500/nginx
echo ""
sleep 2

echo "Deploy candle into dark site and it became bright"
kubectl delete -f candle.yaml
kubectl create -f candle.yaml
echo ""
