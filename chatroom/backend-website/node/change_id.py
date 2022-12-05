import re

node1_log=open("./node1.log","r")
node2_log=open("./node2.log","r")
node1=node1_log.readlines()
node2=node2_log.readlines()
lines=node1 + node2
node1=open("./node1/node1.js","r+")
node2=open("./node2/node2.js","r+")
node1_conf=open("./node1/config/config.toml","r+")
node2_conf=open("./node2/config/config.toml","r+")
todo=[node1,node2]
addresss=["@172.18.5.10:30094","@172.18.5.11:30092"]
out=""
to_change_id=""
to_find_change_id=""
for line in lines:
    if line.find("Error dialing peer")!= -1:
        spl=line.split("conn.ID")[1].split("dialed")
        to_change_id=spl[0].strip()
        to_change_id=re.findall(r'\(.*\)',to_change_id)[0].replace("(","").replace(")","")
        to_find_change_id=spl[1].strip()
        to_find_change_id=re.findall(r'\(.*\)',to_find_change_id)[0].replace("(","").replace(")","")
        filez=todo[0].read(-1)
        todo[0].seek(0)
        filez_str=filez.replace(to_find_change_id,to_change_id)
        out+=to_change_id+addresss[0]+" "
        addresss.pop(0)
        print(addresss)
        todo[0].write(filez_str)
        todo.pop(0)


def replace_empty_block(node):
    node_conf_str=node.read(-1)
    node.seek(0)
    str_find="create_empty_blocks = true"
    str_replace="create_empty_blocks = false"
    node_conf_str=node_conf_str.replace(str_find,str_replace)
    node.write(node_conf_str)

replace_empty_block(node1_conf)
replace_empty_block(node2_conf)
node1_conf.close()
node2_conf.close()
node1.close()
node2.close()
node1_log.close()
node2_log.close()
lls=out.split(" ")
open("out","w").write('"'+lls[0]+'",'+'"'+lls[1]+'"')

