#!/bin/bash
SCANNER="/home/scanner/"
SCANNER_INBOX="${SCANNER}inbox/"
SCANNER_SHUFFLEBOX="${SCANNER}shufflebox/"
SCANNER_OUTBOX="${SCANNER}outbox/"
function process_file(){
  INPUTFILE="${1}"
  if [[ ${INPUTFILE}  ==  *.pdf ]]; then
    echo "Neue pdf Datei:  ${INPUTFILE}"    
    DATEI=$(basename "${INPUTFILE}")
    # zieldateiname bauen  _ocr einfügen 
    DATEI=${DATEI[@]/%.pdf/_ocr.pdf}
    OUTPUTFILE="${SCANNER_OUTBOX}${DATEI}"
    echo "Ausgabedatei:  ${OUTPUTFILE}" 
    echo "Start OCR" > "${OUTPUTFILE}.log"
    ocrmypdf  "${INPUTFILE}" "${OUTPUTFILE}" -l deu  --rotate-pages --rotate-pages-threshold 4.0 --optimize 0
    rm "${OUTPUTFILE}.log"
    if [ -f "${OUTPUTFILE}" ]; then
      rm "${INPUTFILE}"
    else
      echo "OCR für ${INPUTFILE} nicht möglich kopiere Original" 
      mv "${INPUTFILE}" "${SCANNER_OUTBOX}"
    fi
 # else
  #  if   ! [[ $INPUTFILE = *temp_scan_data* ]]; then
   #   echo "Neue andere Datei:  ${INPUTFILE}"  
    #  mv "${INPUTFILE}" "${SCANNER_OUTBOX}"
 #   fi
  fi
}
echo "Version 1.3"
echo "Wait for new file in ${SCANNER_INBOX}"
echo "Write results to ${SCANNER_OUTBOX}"
inotifywait -mq -e close_write  --format %w%f  "${SCANNER_INBOX}"  "${SCANNER_SHUFFLEBOX}" | while read -r TRIGGERED_FILE
do  
echo "Start processing $(TRIGGERED_FILE)"
  mv ${SCANNER_INBOX}*.oxps ${SCANNER_OUTBOX}
  mv ${SCANNER_INBOX}*.xps ${SCANNER_OUTBOX}
  mv ${SCANNER_INBOX}*.jpg  ${SCANNER_OUTBOX}
  mv ${SCANNER_INBOX}*.tif ${SCANNER_OUTBOX}
  mv ${SCANNER_SHUFFLEBOX}*.oxps ${SCANNER_OUTBOX}
  mv ${SCANNER_SHUFFLEBOX}*.xps ${SCANNER_OUTBOX}
  mv ${SCANNER_SHUFFLEBOX}*.jpg  ${SCANNER_OUTBOX}
  mv ${SCANNER_SHUFFLEBOX}*.tif ${SCANNER_OUTBOX}
  #process pdf files in SCANNER_SHUFFLEBOX/
  PDFFILES="${SCANNER_SHUFFLEBOX}*.pdf"
  for PDFFILE in $PDFFILES
  do
    if [ -f "${PDFFILE}" ]; then
      python3 /home/scanner/script/pdfshuffler.py   "$PDFFILE" "${SCANNER_INBOX}"
    fi
  done
  #process pdf files in inbox/
  PDFFILES="${SCANNER_INBOX}*.pdf"
  for PDFFILE in $PDFFILES
  do
    if [ -f "${PDFFILE}" ]; then
      process_file "$PDFFILE"
    fi
  done
  echo "done. Waiting...."
done

