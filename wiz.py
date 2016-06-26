#!/usr/local/python/gcc-5.2.0/3.4.4/bin/python3
######!/usr/local/Python/3.2.2/bin/python3
import subprocess, sys
maxFors="blad"
rmsFors="blad"
maxMove="blad"
rmsMove="blad"
ene="blad - nieznaleziono wartosci energii. Moze dziwny poziomm teorii?? "
## theory det ###
def det(filename):
    detCmd= 'grep -m 1 -e "^ #"  ' + filename
    #print(detCmd)
    rawEn=str(subprocess.check_output(detCmd, shell=True), "utf-8")
    #print(type(rawEn))
    thLevel=rawEn.split('/')[0].split("(")[0].upper()
    thLeve=thLevel.strip()
    thLev=thLeve[1:]
    if " " in thLev:
        thLev=thLev.split()[-1]
    print("poziom theory:", thLev)
    if thLev == "MP2":
        find_str="'UMP2 '"
    #now DFT exception
    elif thLev.startswith("B") or ("LYP" in thLev) or ("PBE" in thLev) or ("M06" in thLev) or ("LC" in thLev) or ("TPSS" in thLev) or\
         ("PW" in thLev) or ("WB" in thLev) or ("81" in thLev) or ("91" in thLev):
        find_str ="'SCF Done:'"
    else:
        find_str=thLev
    return find_str
#global 
############################################
def _in_pres(lista, typ="opt"):
    retv=list()
    global e_type
    for elem in lista: 
        if typ == "opt":
            retv.append(elem.split()[2])
            #print(elem.split() )
        elif typ == "energy":
            is_energy=elem.split()[-1]
            ##print("###", is_energy)
            if is_energy[3:4].isnumeric():
                raw_ene=elem.split()[-1]
            else:
                raw_ene=elem.split()[4]
            if "D" in raw_ene:
                retv.append(_emp2(raw_ene) )
            else:
                retv.append(float(raw_ene))
    return retv
###
def _emp2(energy):
    tab=energy.split("D+")
    potega=pow(10, int(tab[1]) )
    podstawa=float(tab[0])
    best_energy=podstawa*potega
    return best_energy
####
def pres(fir,sec, thi, fou, energy, mode="v"):
    #raw_opt_par=(fir, sec, thi, fou)
    results=list() ##!!!!
    globalmin=False
    fi_val=_in_pres(fir)
    se_val=_in_pres(sec)
    th_val=_in_pres(thi)
    fo_val=_in_pres(fou)
    en_val=_in_pres(energy, typ="energy")
    prevE=0
    NoEner=False
    step_id=1
    thisEner=-1
    for counter in range(len(fi_val)):
        #print(len(en_val), counter)
        if  len(en_val) <= counter:
    	    thisEner=0
    	    NoEner=True
        else:
    	    thisEner=en_val[counter]
        if fi_val[counter] == "********":
            maxF = 99.9
        else:
            maxF=float(fi_val[counter])
        rmsF=float(se_val[counter])
        maxD=float(th_val[counter])
        rmsD=float(fo_val[counter])
        if (maxF < 0.000450):
            fi_val[counter]=" " + fi_val[counter][1:]
        if (rmsF < 0.000300):
            se_val[counter]=" " + se_val[counter][1:]
        if (maxD < 0.001800):
            th_val[counter]=" " + th_val[counter][1:]
        if (rmsD < 0.001200):
            fo_val[counter]=" " + fo_val[counter][1:]
        if (prevE != 0 ):
            #print("gg", type(en_val[counter]), type(prevE) )
            if not NoEner:
                deltaE=thisEner-prevE
        else:
            deltaE=0.0
            if not NoEner:
                globalmin=en_val[counter]
            #print("type", type(deltaE))
        #print(maxF, rmsF, maxD, rmsD, "||", thisEner, deltaE)
        tmp_list=list()
        if mode=="v": print("%3i " %step_id, end=" ")
        tmp_list=[step_id, fi_val[counter] ,se_val[counter], th_val[counter], fo_val[counter], thisEner, deltaE]
        if deltaE > 0:    
            if mode=="v": print(fi_val[counter]," " ,se_val[counter], " ", th_val[counter], " ", fo_val[counter], "||", "%.10f" %thisEner, "||", "+%.10f !!" %deltaE, end=" ")
        else:
            ##print ("::::", en_val[counter], deltaE, type(en_val[counter]), type(deltaE))
            if mode=="v": print(fi_val[counter]," " ,se_val[counter], " ", th_val[counter], " ", fo_val[counter], "||", "%.10f" %thisEner, "||", "%.10f" %deltaE, end="")
            ##print(":::::::::::::")
        if thisEner < globalmin and not NoEner:
            #new minima
            if mode=="v": print(" new minima")
            globalmin=en_val[counter]
            tmp_list.append("new minima")
        else:
            if mode =="v": print()
        prevE=float(thisEner)
        step_id += 1
        results.append(tuple(tmp_list))
    #
    if mode == "v": print("id,  max Force", " RMS Force", " Max Move.", " RMS Move", "||", "    Energy     ",  "        delta E")
    return results
###
def halounaja(file_name, mode="v"):
    if mode=="v": print(file_name, "0.000450 0.000300 0.001800 0.001200" )
    maxForcCmd="grep ' Maximum Force ' " + file_name
    rmsForcCmd="grep ' RMS     Force ' " + file_name
    maxMoveCmd="grep ' Maximum Displacement ' " + file_name
    rmsMoveCmd="grep ' RMS     Displacement ' " + file_name
    theory_level=det(file_name)
    if "MP2" in theory_level:
        eneCmd="grep "+ theory_level  + " " +  file_name
    else:
        eneCmd="grep "+ theory_level  + " " + file_name + " | grep 'A.U.'| grep 'E(' | grep -v 'E(2)  E(j)-E(i) F(i,j)' "
    if mode=="v": print(eneCmd)
    try:
        maxFors=str(subprocess.check_output(maxForcCmd, shell=True), "utf-8").split('\n')[:-1]
        rmsFors=str(subprocess.check_output(rmsForcCmd, shell=True), "utf-8").split('\n')[:-1]
        maxMove=str(subprocess.check_output(maxMoveCmd, shell=True), "utf-8").split('\n')[:-1]
        rmsMove=str(subprocess.check_output(rmsMoveCmd, shell=True), "utf-8").split('\n')[:-1]
        ene=str(subprocess.check_output(eneCmd, shell=True), "utf-8").split('\n')[:-1]
    except subprocess.CalledProcessError:
        if mode =="v": print("wrong exit status strange")
        return "wrong exit status strange"
##
    return pres(maxFors, rmsFors, maxMove, rmsMove, ene, mode)
if len(sys.argv) == 1:
    while True:
        file_name=input("file name: ")
        halounaja(file_name)
elif len(sys.argv) == 2:
    halounaja(sys.argv[1])
else:
    minima_energy=None
    minima_loc=[None, None] #[file, structure]
    all_res=list()
    for file_name in sys.argv[1:]:
        all_res.append(halounaja(file_name, mode="s"))
    for i in range( len(all_res) ):
        if all_res[i] == "wrong exit status strange":
            print("no opt step in", sys.argv[1+i])
            continue
        for j in range( len(all_res[i]) ):   
            if len(all_res[i][j])==8:
                #print(all_res[i][j])
                if minima_energy == None or minima_energy > all_res[i][j][5]:
            	    minima_energy=all_res[i][j][5]
            	    minima_loc=[i,j]
    print("file", sys.argv[1+minima_loc[0]])
    print(all_res[minima_loc[0]][minima_loc[1]])
##
