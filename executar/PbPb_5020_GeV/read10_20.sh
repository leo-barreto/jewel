#!/bin/bash

#Number of the job in question
export NJOB=1000
echo "NJOB= "$NJOB

#exporting eviroment variables necessary for the run
export FileDir="/sampa/fcanedo/IC/mymedf/PbPb_5020_GeV/10_20"
export MacroDir="/sampa/fcanedo/jewel-2.2.0"
export LD_LIBRARY_PATH="/sampa/fcanedo/lhapdf/lib"
export LHAPATH="/sampa/fcanedo/lhapdf/share/lhapdf/PDFsets"
export RIVET_ANALYSIS_PATH="/sampa/fcanedo/rivetanalises"
export HEPMC_FILE="/sampa/fcanedo/jewel-2.2.0/hepmc/PbPb_5020_GeV/cent10_20/read."$NJOB".hepmc"
export YODA_GENERIC_FILE="/sampa/fcanedo/results/histograms/PbPb_5020_GeV/cent10_20/read/read."$NJOB".yoda"
export YODA_SHAPE_FILE="/sampa/fcanedo/results/histograms/PbPb_5020_GeV/cent10_20/read/shape.read."$NJOB".yoda"
export YODA_VN_FILE="/sampa/fcanedo/results/histograms/PbPb_5020_GeV/cent10_20/read/vn.read."$NJOB".yoda"
export YODA_ZHADRON_FILE="/sampa/fcanedo/results/histograms/PbPb_5020_GeV/cent10_20/read."$NJOB".yoda"

chmod 777 $MacroDir/jewel-2.2.0-simple

source /cvmfs/alice.cern.ch/etc/login.sh

eval `alienv printenv VO_ALICE@GSL::v1.16-25`                                   
eval `alienv printenv VO_ALICE@boost::v1.59.0-21`                               
eval `alienv printenv VO_ALICE@HepMC::v2.06.09-13`                              
eval `alienv printenv VO_ALICE@fastjet::v3.2.1_1.024-alice3-1`                  
eval `alienv printenv VO_ALICE@YODA::v1.7.0-1`                                  
eval `alienv printenv VO_ALICE@Rivet::2.6.0-alice1-1`                           

export MED_FILE_NUMBER=$NJOB

if true ; then

if [ -e "$FileDir"/"$MED_FILE_NUMBER".dat.xz ]; then
xz -d "$FileDir"/"$MED_FILE_NUMBER".dat.xz
echo "Medfile exists"
else
echo "Medfile does not exist"
fi

cd $MacroDir/params/PbPb_5020_GeV/
cp read10_20.dat read10_20."$NJOB".dat

sed -i "s/\(NJOB\s\).*/\1"$NJOB"/g" read10_20."$NJOB".dat
sed -i "s/\(LOGFILE\s.*read\.\).*/\1"$NJOB".log/g" read10_20."$NJOB".dat
sed -i "s/\(HEPMCFILE\s.*read\.\).*/\1"$NJOB".hepmc/g" read10_20."$NJOB".dat
sed -i "s/\(MEDIUMPARAMS\s.*read10_20\.\).*/\1"$NJOB".dat/g" read10_20."$NJOB".dat
sed -i "s/\(XSECFILE\s.*read_\).*/\1"$NJOB".dat/g" read10_20."$NJOB".dat
sed -i "s/\(SPLITINTFILE\s.*read_\).*/\1"$NJOB".dat/g" read10_20."$NJOB".dat
sed -i "s/\(PDFFILE\s.*read_\).*/\1"$NJOB".dat/g" read10_20."$NJOB".dat

cd $MacroDir/medparams/PbPb_5020_GeV/
cp read10_20.dat read10_20."$NJOB".dat

sed -i "s/\(MEDFILE\s.*\/\)[0-9]\{1,\}\(\.dat\)/\1"$MED_FILE_NUMBER"\2/g" read10_20."$NJOB".dat
#cat read.$NJOB.dat

cd $MacroDir/integrals
cp xsecs.dat xsecs_read10_20_$NJOB".dat"
cp splitint.dat splitint_read10_20_$NJOB".dat"
cp pdfs.dat pdfs_read10_20_$NJOB".dat"

cd $MacroDir
$MacroDir/jewel-2.2.0-reader $MacroDir/params/PbPb_5020_GeV/read10_20."$NJOB".dat

cd $MacroDir/integrals
rm xsecs_read10_20_$NJOB".dat"
rm splitint_read10_20_$NJOB".dat"
rm pdfs_read10_20_$NJOB".dat"

cd $MacroDir/params/PbPb_5020_GeV/
rm read10_20."$NJOB".dat

cd $MacroDir/medparams/PbPb_5020_GeV/
rm read10_20."$NJOB".dat

if [ ! -e "$FileDir"/"$MED_FILE_NUMBER".dat.xz ]; then
echo ""
xz "$FileDir"/"$MED_FILE_NUMBER".dat
fi

fi

export PSI=0.0
export PSI2=0.0
export PSI3=0.0
export PSI4=0.0

#rivet -a MC_GENERIC --ignore-beams -H $YODA_GENERIC_FILE $HEPMC_FILE
rivet  -a JET_SHAPE --ignore-beams -H $YODA_SHAPE_FILE $HEPMC_FILE
rivet  -a JET_VN --ignore-beams -H $YODA_VN_FILE $HEPMC_FILE
#rivet -a Z_HADRON --ignore-beams -H $YODA_ZHADRON_FILE $HEPMC_FILE
