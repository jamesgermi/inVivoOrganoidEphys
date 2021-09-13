
for n in $(seq -f "%04g" 0 15)
do
  mkdir "/Users/jgermi/Documents/Perelman/MTR/ChenLab/Data/inVivoOrganoid/WorkingData/1300/Recording_$n"

scp -v /Volumes/SynoData/CHEN\ LAB/Forebrain_OrganoidTx/1M_FB2.3_R05-1300/2019-07-17_11-24-58/Recording_$n/TT* /Users/jgermi/Documents/Perelman/MTR/ChenLab/Data/inVivoOrganoid/WorkingData/1300/Recording_$n/

scp -v /Volumes/SynoData/CHEN\ LAB/Forebrain_OrganoidTx/1M_FB2.3_R05-1300/2019-07-17_11-24-58/Recording_$n/*.nev /Users/jgermi/Documents/Perelman/MTR/ChenLab/Data/inVivoOrganoid/WorkingData/1300/Recording_$n/

done