#advant of code 2017
#day 2 Corruption Checksum
#_authour_=chuan
###this problem i can't understand right now, so borrow Auther's answer.

def Array(lines):
    "Parse an iterable of str lines into a 2-D array. If `lines` is a str, splitlines."
    if isinstance(lines, str): lines = lines.splitlines()
    #print(lines)
    return mapt(Vector, lines)
#print('test')
def mapt(fn, *args): 
    "Do a map, and make the results into a tuple."
    #print("mapt, before tuple")
    #print(map(fn, *args))
    return tuple(map(fn, *args))
def Vector(line):
    "Parse a str into a tuple of atoms (numbers or str tokens)."
    #print("in vector, before mapt")
    return mapt(Atom, line.replace(',', ' ').split())

def Atom(token):
    "Parse a str token into a number, or leave it as a str."
    try:
        return int(token)
    except ValueError:
        try:
            return float(token)
        except ValueError:
            return token
arA = Array('''414	382	1515	319	83	1327	116	391	101	749	1388	1046	1427	105	1341	1590
960	930	192	147	932	621	1139	198	865	820	597	165	232	417	19	183
3379	987	190	3844	1245	1503	3151	3349	2844	4033	175	3625	3565	179	3938	184
116	51	32	155	102	92	65	42	48	91	74	69	52	89	20	143
221	781	819	121	821	839	95	117	626	127	559	803	779	543	44	369
199	2556	93	1101	122	124	2714	625	2432	1839	2700	2636	118	2306	1616	2799
56	804	52	881	1409	47	246	1368	1371	583	49	1352	976	400	1276	1240
1189	73	148	1089	93	76	3205	3440	3627	92	853	95	3314	3551	2929	3626
702	169	492	167	712	488	357	414	187	278	87	150	19	818	178	686
140	2220	1961	1014	2204	2173	1513	2225	443	123	148	580	833	1473	137	245
662	213	1234	199	1353	1358	1408	235	917	1395	1347	194	565	179	768	650
119	137	1908	1324	1085	661	1557	1661	1828	1865	432	110	658	821	1740	145
1594	222	4140	963	209	2782	180	2591	4390	244	4328	3748	4535	192	157	3817
334	275	395	128	347	118	353	281	430	156	312	386	160	194	63	141
146	1116	153	815	2212	2070	599	3018	2640	47	125	2292	165	2348	2694	184
1704	2194	1753	146	2063	1668	1280	615	163	190	2269	1856	150	158	2250	2459''')


#print(arA[0][3])
#count = 0
#for row in arA:
#	print(row[9])
#	count = count + 1
#	print(count)
	#count = sum(max(row)-min(row))
#print(count)
#print(arA.splitlines())
an = 0
for row in arA:
	a = max(row)
	#print(a)
	b = min(row)
	#print(b)
	an = an + max(row) - min(row)
#print(an)
def first(iterable, default=None): 
    "The first item in an iterable, or default if it is empty."
    return next(iter(iterable), default)
def evendev(row):
	return first( a // b for a in row for b in row if a > b and a // b == a / b )
aacc=sum(map(evendev, arA))
print(aacc)