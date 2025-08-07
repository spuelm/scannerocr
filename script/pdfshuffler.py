import sys
import os


from PyPDF4 import PdfFileReader, PdfFileWriter

def shuffle_pages(pdf_path,target):
    pdf_writer = PdfFileWriter()
    pdf_reader = PdfFileReader(pdf_path)
    # Rotate page 90 degrees to the right
    docPages=pdf_reader.numPages
    for pagenum in range(docPages//2):
        page= pdf_reader.getPage(pagenum)
        pdf_writer.addPage(page)
        page= pdf_reader.getPage(docPages-pagenum-1)
        pdf_writer.addPage(page)
    tfile= os.path.join(target, os.path.basename(pdf_path))
    with open(tfile, 'wb') as fh:
        pdf_writer.write(fh)
    os.remove(pdf_path)

shuffle_pages(sys.argv[1],sys.argv[2])
