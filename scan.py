import tarfile
import re
import glob

#to be called for each dataset. lists studies containing biorender to stdout, for plottingin R

for filepath in glob.iglob('text/*.tar.gz'):
    #print(filepath)
    tf = tarfile.open(filepath)

    regex_pattern = re.compile(b"biorender", re.IGNORECASE)

    while True:
        tarinfo = tf.next()

        if tarinfo is None:
            break

        fc = tf.extractfile(tarinfo).read()

        result = regex_pattern.findall(fc)
        if len(result)>0:
            print(tarinfo.name)


