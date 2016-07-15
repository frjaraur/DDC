create:
	vagrant up
clean:
	vagrant destroy -f 
	rm -rf ./tmp_deploying_stage

poweroff:
	vboxmanage controlvm ucp-node1 poweroff
	vboxmanage controlvm ucp-node2 poweroff
	vboxmanage controlvm ucp-replica1 poweroff
	vboxmanage controlvm ucp-replica2 poweroff
	vboxmanage controlvm ucp-manager poweroff

poweron:
	vboxmanage startvm ucp-manager --type headless
	vboxmanage startvm ucp-replica1 --type headless
	vboxmanage startvm ucp-replica2 --type headless
	vboxmanage startvm ucp-node1 --type headless
	vboxmanage startvm ucp-node2 --type headless


