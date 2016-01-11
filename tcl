#!/bin/sh

echo "-------------------------"
echo "        tcl tool         "
echo "  support By ArDiaN   "
echo "-------------------------"
echo ""

if test $1 = "-l"
then
  echo "list tcl from $2"
  grep "source scripts" $2
  echo ""
  exit
fi

if test $# -lt 3 
then
  echo "Using :"
  echo ""
  echo "   ./tcl -t nameconfig nametcl"
  echo ""
  echo "   -t : add tcl for config"
  echo ""
  echo "   for exp ./tcl -t eggo.conf eggoez.tcl"
  echo "   note: can you add tcl for dir scripts only"
  echo ""
  exit
fi

if ! test -s $2
then
  echo "Say Problem: config file $2 Not Found!!"
  echo ""
  exit
fi

if test $1 = "-t"
then

  ada=`grep "source scripts/$3" $2`
  if test -n "$ada"
  then
    echo "Problem : $3 already on $2"
    echo ""
    exit
  fi
  
  if ! test -s scripts/$3
  then
    echo "Problem : file $3 no such name or dir from /scripts"
    echo ""
    exit
  else 
    echo "source scripts/$3" >> $2
    echo "$3 already add for $2"
  fi
fi

echo ""

