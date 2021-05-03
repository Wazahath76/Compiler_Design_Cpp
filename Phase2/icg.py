import sys
import subprocess
import re

# myinput = open('myinput.in')
myoutput = open('icg_quad.txt', 'w')

filename = input("Enter input file name: ")

subprocess.run(['flex','lex_analyser.l'])
subprocess.run(["bison","-d","sym_table.y"])
process = subprocess.Popen(['./a.out < '+filename],
                     stdout=subprocess.PIPE, 
                     stderr=subprocess.PIPE,shell=True, universal_newlines = True)
stdout, stderr = process.communicate()
print(stdout,stderr)
stdout = stdout.split('\n')

txt_flag = 0
for i in stdout:
    if i.startswith('Operator'):
        txt_flag = 1
    elif txt_flag ==1:
        if i.startswith('----'):
            break
        elif i=="":
            pass
        else:
            myoutput.write(i+"\n")

myoutput.close()
# subprocess.call(["./a.out < ex.cpp"],shell=True,text=True)



f = open("icg_quad.txt","r")

list_of_lines = f.readlines()

# print(list_of_lines)
# print(list_of_lines)



dictValues = dict()
constantFoldedList = []
print("Quadruple form after Dead Code Elimination, Code Propogation, Code Folding, Common Subexpression Elimination")
print("-------------------------------------")
code_rep = dict()

list_code_rep = []

for i in list_of_lines:
    i = i.strip("\n")
    op,arg1,arg2,res = i.split()
    if(op in ["+","-","*","/",">","<","!=","<=",">=","=="]):
        if(arg1.isdigit() and arg2.isdigit()):
        	flag = 0
        	for key,value in code_rep.items():
        		if [op,arg1,arg2] == value:
        			dictValues[res] = dictValues[key]
        			print("=",key,"NULL",res)
        			constantFoldedList.append(["=",key,"NULL",res])
        			flag = 1
        			break
        	if flag:
        		continue
        	result = eval(arg1+op+arg2)
        	dictValues[res] = result
        	print("=",result,"NULL",res)
        	constantFoldedList.append(["=",result,"NULL",res])
        elif(arg1.isdigit()):
            if(arg2 in dictValues):
            	flag = 0
            	for i in list_code_rep[::-1]:
            		if arg2 == i[3]:
            			break
            		elif [op,arg1,arg2] == i[:3]:
            			dictValues[res] = dictValues[i[3]]
            			print("=",i[3],"NULL",res)
            			constantFoldedList.append(["=",i[3],"NULL",res])
            			flag = 1
            			break
            	if flag:
            		continue
            	result = eval(arg1+op+dictValues[arg2])
            	dictValues[res] = result
            	print("=",result,"NULL",res)
            	constantFoldedList.append(["=",result,"NULL",res])
            else:
                print(op,arg1,arg2,res)
                constantFoldedList.append([op,arg1,arg2,res])
        elif(arg2.isdigit()):
            if(arg1 in dictValues):
                flag = 0
                for i in list_code_rep[::-1]:
                    if arg1 == i[3]:
                        break
                    elif [op,arg1,arg2] == i[:3]:
                        dictValues[res] = dictValues[i[3]]
                        print("=",i[3],"NULL",res)
                        constantFoldedList.append(["=",i[3],"NULL",res])
                        flag = 1
                        break
                if flag:
                    continue
                result = eval(dictValues[arg1]+op+arg2)
                dictValues[res] = result
                print("=",result,"NULL",res)
                constantFoldedList.append(["=",result,"NULL",res])
            else:
                print(op,arg1,arg2,res)
                constantFoldedList.append([op,arg1,arg2,res])
        else:

            flag_1 = 0
            for i in list_code_rep[::-1]:
                if arg1 == i[3]:
                    break
                elif [op,arg1,arg2] == i[:3]:
                    flag_1 = 1
                    break
            flag_2 = 0
            for i in list_code_rep[::-1]:
                if arg2 == i[3]:
                    break
                elif [op,arg1,arg2] == i[:3]:
                    flag_2 = 1
                    break

            if flag_1 and flag_2:
                dictValues[res] = dictValues[i[3]]
                print("=",i[3],"NULL",res)
                constantFoldedList.append(["=",i[3],"NULL",res])
                continue

            flag1=0
            flag2=0
            arg1Res = arg1
            if(arg1 in dictValues):
                arg1Res = str(dictValues[arg1])
                flag1 = 1
            arg2Res = arg2
            if(arg2 in dictValues):
                arg2Res = str(dictValues[arg2])
                flag2 = 1
            if(flag1==1 and flag2==1):
                result = eval(arg1Res+op+arg2Res)
                dictValues[res] = result
                print("=",result,"NULL",res)
                constantFoldedList.append(["=",result,"NULL",res])
            else:
                print(op,arg1Res,arg2Res,res)
                constantFoldedList.append([op,arg1Res,arg2Res,res])
        code_rep[res] = [op,arg1,arg2]
        list_code_rep.append([op,arg1,arg2,res])
            
    elif(op=="="):
        if(arg1.isdigit()):
            dictValues[res]=arg1
            print("=",arg1,"NULL",res)
            constantFoldedList.append(["=",arg1,"NULL",res])
        else:
            if(arg1 in dictValues):
                dictValues[res]= str(dictValues[arg1])
                print("=",dictValues[arg1],"NULL",res)
                constantFoldedList.append(["=",dictValues[arg1],"NULL",res])
            else:
                print("=",arg1,"NULL",res)
                constantFoldedList.append(["=",arg1,"NULL",res])
       	list_code_rep.append([op,arg1,arg2,res])

    elif(op=="not"):
    	print(op,arg1,arg2,res)
    	dictValues[res] = op+" "+str(dictValues[arg1])
    	constantFoldedList.append([op,arg1,arg2,res])

    elif op == "return":
        print(op,arg1,arg2,res)
        constantFoldedList.append([op,arg1,arg2,res])  
        break

    else:
    	if arg1 in dictValues:
    		print(op,dictValues[arg1],arg2,res)
    		constantFoldedList.append([op,dictValues[arg1],arg2,res])
    	elif arg2 in dictValues:
    		print(op,arg1,dictValues[arg2],res)
    		constantFoldedList.append([op,arg1,dictValues[arg2],res])
    	else:
    		print(op,arg1,arg2,res)
    		constantFoldedList.append([op,arg1,arg2,res])       	

print("\n")
print("Constant folded expression - ")
print("--------------------")
for i in constantFoldedList:
	if i[0].startswith('return'):
		print(i[0]+" "+i[1])
	elif(i[0]=="="):
	    print(i[3],i[0],i[1])
	elif(i[0] in ["+","-","*","/","==","<=","<",">",">="]):
	    print(i[3],"=",i[1],i[0],i[2])
	elif(i[0] in ["if","goto","label","not"]):
	    if(i[0]=="if"):
	        print(i[0],i[1],"goto",i[3])
	    if(i[0]=="goto"):
	        print(i[0],i[3])
	    if(i[0]=="label"):
	        print(i[3],":")
	    if(i[0]=="not"):
	        print(i[3],"=",i[0],i[1])

                
        


