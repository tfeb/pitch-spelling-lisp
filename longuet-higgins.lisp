;longuet-higgins.lisp

#|
Copyright © 2002-2003 by David Meredith. All rights reserved.
|#
(setf *verbose-eval-selection* t)
(setf *save-local-symbols* t)
;(load #P"hd:Users:davemeredith:files:MIDI-to-notation:03 Pitch-spelling:2002-09-26-dphil:programs:lisp:pitch-spelling-common.lisp")

(defvar mum 7)
(setf mum 7)
(defvar muc 12)
(setf muc 12)

(defun well-formed-number-string-p (s)
  (let ((wf t))
    (dotimes (i (length s) wf)
      (if (not (or (<= (char-code #\0) (char-code (char s i)) (char-code #\9))
                   (and (= i 0) 
                        (equalp (char s i) #\-))))
        (setf wf nil)))))

(defun pathname-directory-to-string (pn)
  (let ((pns (concatenate 'string (second pn) ":")))
    (dolist (pnelt (cddr pn) pns)
      (setf pns (concatenate 'string
                             pns 
                             pnelt
                             ":")))))

(defun pn-p (pn-as-input)
  (let* ((n (if (stringp pn-as-input)
              (string-upcase pn-as-input)
              (string-upcase (string pn-as-input))))
         (n (if (and (>= (length n) 2)
                     (member (elt n 1) '(#\- #\1 #\2 #\3 #\4 #\5 #\6 #\7 #\8 #\9)))
              (concatenate 'string 
                           (string (elt n 0))
                           "N"
                           (subseq n 1))
              n))
         (n (if (and (>= (length n) 3)
                     (eq (elt n 1) #\#))
              (concatenate 'string 
                           (string (elt n 0))
                           "S"
                           (subseq n 2))
              n))
         (l (string (elt n 0)))
         (i (do* ((i "")
                  (x 2)
                  (j (string (elt n (- x 1))) (string (elt n (- x 1))))
                  (i (concatenate 'string i j) (concatenate 'string i j))
                  (x (+ 1 x) (+ 1 x)))
                 ((or (>= x (length n))
                      (member (elt n (- x 1)) '(#\- #\1 #\2 #\3 #\4 #\5 #\6 #\7 #\8 #\9)))
                  i)))
         (is-good-i (well-formed-inflection-p i))
         (o (if is-good-i
              (do* ((y (length i))
                    (x (+ y 2))
                    (o (string (elt n (- x 1))))
                    (x (+ 1 x) (+ 1 x))
                    (j (if (<= x (length n))
                         (string (elt n (- x 1)))
                         "")
                       (if (<= x (length n))
                         (string (elt n (- x 1)))
                         ""))
                    (o (if (equalp j "") o
                           (concatenate 'string o j))
                       (if (equalp j "") o
                           (concatenate 'string o j))))
                   ((equalp j "")
                    o))))
         (oasa (if is-good-i (read-from-string o)))
         (m (if is-good-i (position l
                                    '("A" "B" "C" "D" "E" "F" "G")
                                    :test #'equalp)))
         (cdash (if is-good-i (elt '(0 2 3 5 7 8 10) m)))
         (e (if is-good-i (cond ((equalp i "N") 0)
                                ((equalp (elt i 0) #\F) (* -1 (length i)))
                                ((member (elt i 0) '(#\S #\#)) (length i)))))
         (om (if is-good-i (if (or (= m 1) (= m 0))
                             oasa (- oasa 1))))
         (pc (if is-good-i (+ e cdash (* muc om))))
         (pm (if is-good-i (+ m (* om mum)))))
    (if is-good-i (list pc pm))))

(defun well-formed-inflection-p (i-as-input)
  (let ((i (string-upcase i-as-input)))
    (or (equalp i "N")
        (let ((wf t))
          (dotimes (j (length i) wf)
            (if (not (equalp (char i j) #\F))
              (setf wf nil))))
        (let ((wf t))
          (dotimes (j (length i) wf)
            (if (not (member (char i j) '(#\S #\#)))
              (setf wf nil)))))))
#|
This file contains a LISP port of the 
pitch-spelling portion of the
program
music.p given in Appendix A of

@incollection{LonguetHiggins1987a,
	author = "H. Christopher Longuet-Higgins",
	year = 1987,
	title = "The Perception of Melodies",
	editor = "H. Christopher Longuet-Higgins",
	booktitle = "Mental Processes: Studies in Cognitive Science",
	publisher = "British Psychological Society/MIT Press",
	address = "London, England and Cambridge, Mass.",
	pages = "105--129",
	note = "Same as \citet{LonguetHiggins1976,LonguetHiggins1993}"}
@article{LonguetHiggins1976,
	author = "H. Christopher Longuet-Higgins",
	year = 1976,
	title = "The Perception of Melodies",
	journal = "Nature",
	volume = 263,
	number = 5579,
	pages = "646--653",
	note = "Republished as \citet{LonguetHiggins1993,LonguetHiggins1987a}"}
@incollection{LonguetHiggins1993,
	author = "H. Christopher Longuet-Higgins",
	year = 1993,
	title = "The Perception of Melodies",
	editor="Stephan M. Schwanauer and David A. Levitt",
	booktitle="Machine Models of Music",
	publisher="M.I.T. Press",
	address="Cambridge, Mass.",
	ISBN = "0-262-19319-1",
	pages = "471--495",
	note = "Published earlier as \citet{LonguetHiggins1987a,LonguetHiggins1976}"
}

LonguetHiggins1987a
p.110		every musical note is assigned co-ordinates (x,y,z)
		x = number of rp5
		y = number of rma3
		z = number of rp8
p.111		position of a note is its distance above middle C (actually cn3 later on, I think).
		position, p=7x + 4y + 12z
		conventional name (i.e., pitch name octave equivalence class, an, gs, cf etc) is
		determined by its `sharpness' q = x + 4y. This is the same as Temperley's
		TPC (and Regener's quint class, and Rowe's) with C = 0. So Ab = -4, A = 3 etc.

		`a given choice of p severly restricts the range of possible values of q
		it can be shown that 7p - q = 12(4x+2y+7z)
		Need to restrict q to a fairly limited range of values.
		q never changes from one note to the next by more than 11 units of sharpness
			But is it logically possible for it to do so?
p.112		Could try to keep intervals between consecutive tones in the melody diatonic
		but prefers to keep interval between tones and `the first note' diatonic.
			Surely, what we need is to keep the interval from the tones to the current
			tonic diatonic.
p.113		Cannot assume first note is keynote
		music modulates - keynote changes over the course of a piece (B minor Fugue from Book 1)
		if X Y Z are three notes that are separated by chromatic intervals then there is
		always an alternative, simpler interpretation of the middle note Y which transforms
		both intervals into diatonic ones.

		If W X Y Z are four notes and XY is a chromatic interval then W X and Y Z must be
		non-chromatic and at least one of W Y or X Z must also be diatonic
		`If the interpretations of W, X, Y and Z based on the current key violate this rule,
		then the tonality of the note Y is reinterpreted in such a way as to make X Y a 
		diatonic interval, and to force a modulation into a key to which Y belongs.'

p.114		Rule concerning tonal interpretation of ascending semitones.
		If X Y form an asending semitone and the sharpness of Y relative to the
		tonic is 2, 3, 4 or 5, then the X must be reassigned a relative
		sharpness 7, 8, 9 or 10.

		Another rule: conflate repeated notes or notes separated by an octave (in melodies).

		The tonic may be determined from the first two notes, and it will either be the
		first note or the note a fifth below it.

		`This rule, and the absence of any more delicate tests of modulation than those
		already described, are undoubtedly the weakest links in the tonal section of the
		program.'

		The tonal rules should not be expected to apply to accompanied melodies, nor compound melodies.
		Contextual constraints on chromatic intervals will often be violated at phrase boundaries.
		Sometimes radical changes in notation occur in order to make it easier for the performer to read
		(e.g., Waldesrauschen, Raindrop Prelude).

hclh-pitch-spell takes as input a list of sublists, each sublist has the form
(pitch onset-time offset-time)
where pitch is number of semitones above cn3 and onset-time and offset-time are in cs.

|#

(defun tuneup (&optional (nlist (sort (with-open-file (notefile
                                                       (choose-file-dialog))
                                        (read notefile)) #'< :key #'second)))
  (let* ((ints (intervals (mapcar #'pitch nlist)))
         (x0 (first nlist))
         (place (lh-int (pitch x0)))
         (output-list nil)
         (new-output-list nil))
    (dolist (x nlist output-list)
      (let* ((span (- (pitch x) (pitch x0)))
             (deg (if (zerop (res span))
                    0
                    (first ints))))
        (if (zerop deg) 
          nil
          (setf ints (cdr ints)))
        (setf x0 x
              output-list (append output-list
                                  (list (append x
                                                (list span deg)))))))
    (dolist (note output-list new-output-list)
      (let* ((enh nil)
             (max-index 17)
             (min-index -13))
        (setf place (+ place (deg note)))
        (cond ((> place max-index) (setf enh t
                                         place (- place 12)))
              ((< place min-index) (setf enh t
                                         place (+ place 12)))
              (t (setf enh nil)))
        (setf new-output-list
              (append new-output-list
                      (list (append note
                                    (list place
                                          (get-symbol place))
                                    (if enh (list 'enh))))))))))

(defun get-symbol (place)
  (let* ((symbols (list "Fff" "Cff" "Gff" "Dff" "Aff" "Eff" "Bff" "Ff" "Cf" "Gf" "Df" "Af" "Ef" "Bf"
                        "Fn" "Cn" "Gn" "Dn" "An" "En" "Bn" "Fs" "Cs" "Gs" "Ds" "As" "Es" "Bs" "Fss" "Css" "Gss"
                        "Dss" "Ass" "Ess" "Bss")))
    (elt symbols (+ place 15))))

(defun deg (note)
  (fifth note))

(defun intervals (input-tune)
  (let* ((tune (simplify input-tune))
         (flag nil)
         (ints nil)
         (y (first tune))
         (tune (cdr tune))
         z x k l m n)
    (if tune
      (progn (setf z (first tune)
                   tune (cdr tune)
                   k y
                   m 0
                   n (lh-int (- z k)))
             (if (or (= 3 n)
                     (and (/= n -3)
                          (< n 0)))
               (setf k (+ 5 k)
                     m 1
                     n (1+ n)))
             (do ()
                 ((null tune)
                  (reverse (cons (- n m) ints)))
               (setf x y 
                     y z
                     z (first tune)
                     tune (cdr tune))
               (multiple-value-setq (flag k l m n x y z)
                 (hark flag k l m n x y z))
               (setf ints (cons (- m l) ints)))))))

(defun hark (flag k l m n x y z)
  (setf l m
        m n
        n (lh-int (- z k)))
  (if (and flag
           (> (abs (1- n)) 6))
    (multiple-value-setq (m y k x l z n)
      (modulate m y k x l z n)))
  (setf flag nil)
  (cond ((< (abs (- n m)) 7) (values flag k l m n x y z))
        ((> (abs (- m l)) 6) (multiple-value-setq (m y k x l z n)
                               (modulate m y k x l z n)))
        ((and (> (abs (- n l)) 6)
              (< l 7))
         (setf flag t))
        ((and (= 7 (- n m))
              (< n 6))
         (setf m (+ m 12))))
  (values flag k l m n x y z))

(defun modulate (m y k x l z n)
  (cond ((> m 2) (setf k (1- y)))
        ((< m -1) (setf k (+ y 6)))
        (t (values m y k x l z n)))
  (setf l (lh-int (- x k))
        m (lh-int (- y k))
        n (lh-int (- z k)))
  (values m y k x l z n))

;;;lh-int

(defun lh-int (x)
  (- (res (+ (* 7 x) 5)) 5))

#|
function lh-int x;
  res(7*x+5)-5;
end;

This function computes

(7 * x + 5) mod 12 - 5

`$lh-int x$ is the diatonic interval between two notes
separated by x keyboard semitones.'

The diatonic interval is encoded as an integer indicating
the number of rising perfect fifths to which it is
octave equivalent. In the following table, the third column is the chroma
interval

	i	
rmi2	-5	1
rmi6	-4	8
rmi3	-3	3
rmi7	-2	10
rp4	-1	5
p1	0	0
rp5	1	7
rma2	2	2
rma6	3	9
rma3	4	4
rma7	5	11
ra4	6	6

|#

;;;res
;;;;;;

(defun res (x)
  (mod x 12))

#|
1 function res x
2  loopif x < 0 then x + 12 -> x close;
3  erase (x//12);
4 end;

`$res x$ is the remainder on division of x by 12.'
\citep[p.128]{LonguetHiggins1987a}

This suggests that res x is simply x mod 12.

Line 2 certainly returns x mod 12 for negative x since it
gives the least positive value of x + 12n for integer n.

What does line 3 mean?
x//12 could mean (floor x 12), and, like floor, it could
return two values, x div 12 and x mod 12. The erase
could be a way of `deleting' the first value and getting
at the second value. It may be that the operator x//y is
only defined for positive x.

|#
;;;;;;

(defun simplify (tune)
  (let ((y (1- (first tune))))
    (remove-if #'null
               (mapcar #'(lambda (x)
                           (if (> (res (- x y)) 0)
                             (setf y x)
                             (progn (setf y x)
                                    nil)))
                       tune))))

(defun pitch (note)
  (first note))

#|
Testing multiple value setq:

(defun test-mvs ()
  (let* ((x 1)
         (y 2)
         (z 3))
    (multiple-value-setq (x y z)
      (change-x-y-z x y z))
    (list x y z)))

(defun change-x-y-z (x y z)
  (setf x 4 y 5 z 6)
  (values x y z))
|#

(defun batch-lh-pitch-spell (&optional (print-pitch-names nil))
  (let* ((dir (directory (concatenate 'string
                                      (pathname-directory-to-string (pathname-directory (choose-directory-dialog)))
                                      "*.opnd-m")))
         (total-number-of-errors 0)
         (total-number-of-notes 0)
         (number-of-errors 0)
         (number-of-notes 0))
    (mapcar #'(lambda (filename)
                (multiple-value-setq (number-of-errors
                                      number-of-notes)
                  (lh-pitch-spell print-pitch-names
                                  filename))
                (setf total-number-of-errors (+ total-number-of-errors number-of-errors)
                      total-number-of-notes (+ total-number-of-notes number-of-notes))) 
            dir)
    (format t "~%Total number of notes = ~d~%" total-number-of-notes)
    (format t "Total number of errors = ~d~%" total-number-of-errors)
    (format t "Percentage correct = ~,2f%~%" (* 100 (- 1 (/ total-number-of-errors total-number-of-notes))))))

(defun lh-pitch-spell (&optional (print-pitch-names nil)
                                 (opnd-filename (choose-file-dialog)))
  (let* ((opnd (sort (with-open-file (opnd-file
                                      opnd-filename)
                       (read opnd-file))
                     #'<
                     :key #'first))
         (LH-nlist (mapcar #'(lambda (x)
                               (list (- (first (pn-p (second x))) 27)
                                     (first x)
                                     (+ (first x) (third x))))
                           opnd))
         (tuneup-output (tuneup lh-nlist))
         (pitch-name-sequence (mapcar #'compute-pitch-name
                                      tuneup-output))
         (error-list (remove-if #'null
                                (mapcar #'(lambda (pitch-name opnd-datapoint)
                                            (if (not (pitch-name-equal-p pitch-name (second opnd-datapoint)))
                                              (list opnd-datapoint pitch-name)))
                                        pitch-name-sequence
                                        opnd)))
         (number-of-errors (list-length error-list))
         
         ;;;;;;;;NOW FOR PITCH SEQUENCE TRANSPOSED BY RD2
         (pitch-name-sequence-transposed-rd2 (mapcar #'(lambda (pitch-name)
                                                         (pn-tran pitch-name 'rd2))
                                                     pitch-name-sequence))
         (rd2-error-list (remove-if #'null
                                (mapcar #'(lambda (pitch-name opnd-datapoint)
                                            (if (not (pitch-name-equal-p pitch-name (second opnd-datapoint)))
                                              (list opnd-datapoint pitch-name)))
                                        pitch-name-sequence-transposed-rd2
                                        opnd)))
         (rd2-number-of-errors (list-length rd2-error-list))

         ;;;;;;;;NOW FOR PITCH SEQUENCE TRANSPOSED BY FD2
         (pitch-name-sequence-transposed-fd2 (mapcar #'(lambda (pitch-name)
                                                         (pn-tran pitch-name 'fd2))
                                                     pitch-name-sequence))
         (fd2-error-list (remove-if #'null
                                (mapcar #'(lambda (pitch-name opnd-datapoint)
                                            (if (not (pitch-name-equal-p pitch-name (second opnd-datapoint)))
                                              (list opnd-datapoint pitch-name)))
                                        pitch-name-sequence-transposed-fd2
                                        opnd)))
         (fd2-number-of-errors (list-length fd2-error-list))

         ;;;NOW DETERMINE BEST SPELLING OF THE THREE POSSIBILITIES
         (best-spelling (position (min number-of-errors
                                       rd2-number-of-errors
                                       fd2-number-of-errors)
                                  (list number-of-errors
                                        rd2-number-of-errors
                                        fd2-number-of-errors)))
         (pitch-name-sequence (elt (list pitch-name-sequence
                                         pitch-name-sequence-transposed-rd2
                                         pitch-name-sequence-transposed-fd2)
                                   best-spelling))
         (error-list (elt (list error-list
                                rd2-error-list
                                fd2-error-list)
                          best-spelling))
         (number-of-errors (elt (list number-of-errors
                                      rd2-number-of-errors
                                      fd2-number-of-errors)
                                best-spelling))
         (percentage-correct (* 100 (- 1 (/ number-of-errors (list-length opnd))))))
    (format t "~%~%PROGRAM: Longuet-Higgins~%")
    (format t "FILE: ~s~%" (pathname-name opnd-filename))
    (format t "Number of errors = ~d~%" number-of-errors)
    (format t "Number of notes = ~d~%" (list-length opnd))
    (format t "Percentage correct = ~,2f%~%" percentage-correct)
    (format t "Best spelling obtained when computed spelling transposed by ~a.~%"
            (cond ((= best-spelling 0) 'p1)
                  ((= best-spelling 1) 'rd2)
                  ((= best-spelling 2) 'fd2)))
    (format t "ERROR LIST:")
    (pprint error-list)
    (if print-pitch-names 
      (progn (format t "~%COMPUTED PITCH NAME SEQUENCE:")
             (pprint (mapcar #'string-downcase pitch-name-sequence))
             (format t "~%ORIGINAL PITCH NAME SEQUENCE:")
             (pprint (mapcar #'string-downcase (mapcar #'second opnd)))))
    (values number-of-errors
            (list-length opnd))))

(defun pitch-name-equal-p (pn1 pn2)
  (equalp (pn-p pn1) (pn-p pn2)))

(defun compute-pitch-name (note)
  (let* ((index (sixth note))
         (quint (1+ index))
         (inflection (floor quint 7))
         (lh-chromatic-pitch (first note))
         (chromatic-pitch (+ lh-chromatic-pitch 36)); this makes Cn4 = 48
         (undisplaced-chromatic-pitch (- chromatic-pitch inflection))
         (asa-octave (floor undisplaced-chromatic-pitch 12)))
    (string-downcase (concatenate 'string
                                  (seventh note)
                                  (format nil "~d" asa-octave)))))

(defun opnd-to-LH-notefile ()
  (let* ((input-file-name (choose-file-dialog))
         (opnd (with-open-file (opnd-file
                                input-file-name)
                 (read opnd-file)))
         (LH-nlist (sort (mapcar #'(lambda (x)
                                     (list (- (first (pn-p (second x))) 27)
                                           (first x)
                                           (+ (first x) (third x))))
                                 opnd)
                         #'< :key #'second))
         (output-directory (choose-directory-dialog))
         (output-file-name (pathname (concatenate 'string
                                                  (pathname-directory-to-string 
                                                   (pathname-directory
                                                    output-directory))
                                                  (pathname-name input-file-name)
                                                  ".LH-notefile"))))
    (with-open-file (notefile
                     output-file-name
                     :direction :output
                     :if-exists :rename)
      (pprint LH-nlist notefile))))





(defun string-to-number (s)
  (if (well-formed-number-string-p s)
    (if (string-is-negative-p s)
      (let ((n 0))
        (dotimes (i (- (length s) 1) (* -1 n))
          (setf n (+ (* 10 n)
                     (- (char-code (elt s (+ 1 i)))
                        (char-code #\0))))))
      (let ((n 0))
        (dotimes (i (length s) n)
          (setf n (+ (* 10 n)
                     (- (char-code (elt s i))
                        (char-code #\0)))))))))

(defun string-is-negative-p (s)
  (equalp #\- (char s 0)))

(defun pn-tran (pitch-name pitch-interval-name)
  (p-pn (p-tran (pn-p pitch-name) (pin-pi pitch-interval-name))))

(defun pin-pi (pitch-interval-name)
  (let* ((pin (if (stringp pitch-interval-name)
                (string-upcase pitch-interval-name)
                (string-upcase (string pitch-interval-name))))
         (d (char pin 0))
         (d (if (member d '(#\F #\R) :test #'equalp) (string d) ""))
         (ty (do* ((ty "")
                   (x (if (equalp d "") 0 1))
                   (j (string (elt pin x)) (string (elt pin x)))
                   (ty (concatenate 'string ty j) (concatenate 'string ty j))
                   (x (+ 1 x) (+ 1 x)))
                  ((or (>= x (length pin))
                       (member (elt pin x) '(#\1 #\2 #\3 #\4 #\5 #\6 #\7 #\8 #\9)))
                   ty)))
         (ty-error (not (well-formed-interval-type-p ty)))
         (s (if (not ty-error)
              (do* ((y (length ty))
                    (x (if (equalp d "") y (+ y 1)))
                    (s (string (elt pin x)))
                    (x (+ 1 x) (+ 1 x))
                    (j (if (< x (length pin))
                         (string (elt pin x))
                         "")
                       (if (< x (length pin))
                         (string (elt pin x))
                         ""))
                    (s (if (equalp j "") s
                           (concatenate 'string s j))
                       (if (equalp j "") s
                           (concatenate 'string s j))))
                   ((equalp j "")
                    s))))
         (s-error (if (not ty-error) (not (well-formed-number-string-p s))))
         (s-dash (if (or s-error ty-error) nil (string-to-number s)))
         (pmintvar (if (or s-error ty-error) nil (if (equalp d "f") (- 1 s-dash) (- s-dash 1))))
         (mint-dash (if (or s-error ty-error) nil (MOD (abs pmintvar) mum)))
         (cint-dash (if (or s-error ty-error) nil (elt '(0 2 4 5 7 9 11) mint-dash)))
         (pcintone (if (or s-error ty-error) nil (+ cint-dash
                                                    (* muc
                                                       (FLOOR (abs pmintvar)
                                                            mum)))))
         (t-dash (if (or s-error ty-error) nil (elt '("p" "ma" "ma" "p" "p" "ma" "ma") mint-dash)))
         (e (if (or s-error ty-error) nil
                (cond ((and (equalp ty "p") (equalp t-dash "p")) 0)
                      ((and (equalp t-dash "p") (equalp (char ty 0) #\D)) (* (- 1) (length ty)))
                      ((and (equalp t-dash "p") (equalp (char ty 0) #\A)) (length ty))
                      ((and (equalp ty "ma") (equalp t-dash "ma")) 0)
                      ((and (equalp t-dash "ma") (equalp ty "mi")) (- 1))
                      ((and (equalp t-dash "ma") (equalp (char ty 0) #\D)) (* (- 1)
                                                                             (+ (length ty) 1)))
                      ((and (equalp t-dash "ma") (equalp (char ty 0) #\A)) (length ty)))))
         (pcintvar (if (or s-error ty-error) nil
                       (if (< pmintvar 0) (* (- 1) (+ e pcintone)) (+ e pcintone)))))
    (list pcintvar pmintvar)))

(defun well-formed-interval-type-p (ty)
  (or (member ty '("MA" "MI" "P") :test #'equalp)
      (let ((wf t))
        (dotimes (j (length ty) wf)
          (if (not (equalp (char ty j) #\D))
            (setf wf nil))))
      (let ((wf t))
        (dotimes (j (length ty) wf)
          (if (not (equalp (char ty j) #\A))
            (setf wf nil))))))

(defun p-tran (p i)
  (mapcar #'+ p i))

(defun p-pn (p)
  (let* ((m (p-m p))
         (l (elt '("A" "B" "C" "D" "E" "F" "G") m))
         (gc (p-gc p))
         (cdash (elt '(0 2 3 5 7 8 10) m))
         (e (- gc cdash))
         (i "")
         (i (cond ((< e 0) (dotimes (j (- e) i) (setf i (concatenate 'string i "f"))))
                  ((> e 0) (dotimes (j e i) (setf i (concatenate 'string i "s"))))
                  ((= e 0) "n")))
         (om (p-om p))
         (oasa (if (or (= m 0) (= m 1))
                 om
                 (+ 1 om)))
         (o (format nil "~D" oasa)))
    (concatenate 'string l i o)))

(defun p-om (p)
  (floor (p-pm p) mum))

(defun p-pm (p)
  (second p))

(defun p-gc (p)
  (- (p-pc p)
     (* muc (p-om p))))

(defun p-pc (p)
  (first p))

(defun p-m (p)
  (mod (p-pm p) mum))
