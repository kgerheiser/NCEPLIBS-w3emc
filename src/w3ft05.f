C> @file
C
C> SUBPROGRAM: W3FT05         CONVERT (145,37) TO (65,65) N. HEMI. GRID
C>   AUTHOR:  JONES,R.E.      ORG:  W342      DATE: 85-04-08
C>
C> ABSTRACT:  CONVERT A NORTHERN HEMISPHERE 2.5 DEGREE LAT.,LON. 145 BY
C>   37 GRID TO A POLAR STEREOGRAPHIC 65 BY 65 GRID. THE POLAR
C>   STEREOGRAPHIC MAP PROJECTION IS TRUE AT 60 DEG. N. , THE MESH
C>   LENGTH IS 381 KM. AND THE ORIENTION IS 80 DEG. W.
C>
C> PROGRAM HISTORY LOG:
C>   85-04-08  R.E.JONES
C>   91-07-30  R.E.JONES   CONVERT TO CRAY CFT77 FORTRAN
C>   92-05-02  R.E.JONES   ADD SAVE
C>
C> USAGE:  CALL W3FT05(ALOLA,APOLA,W1,W2,LINEAR)
C>
C>   INPUT VARIABLES:
C>     NAMES  INTERFACE DESCRIPTION OF VARIABLES AND TYPES
C>     ------ --------- -----------------------------------------------
C>     ALOLA  ARG LIST  145*37 GRID 2.5 LAT,LON GRID N. HEMI.
C>                      5365 POINT GRID IS TYPE 29 OR 1D HEX O.N. 84
C>     LINEAR ARG LIST  1 LINEAR INTERPOLATION , NE.1 BIQUADRATIC
C>
C>   OUTPUT VARIABLES:
C>     NAMES  INTERFACE DESCRIPTION OF VARIABLES AND TYPES
C>     ------ --------- -----------------------------------------------
C>     APOLA  ARG LIST  65*65 GRID OF NORTHERN HEMI.
C>                      4225 POINT GRID IS TYPE 27 OR 1B HEX O.N. 84
C>     W1     ARG LIST  65*65 SCRATCH FIELD
C>     W2     ARG LIST  65*65 SCRATCH FIELD
C>
C>   SUBPROGRAMS CALLED:
C>     NAMES                                                   LIBRARY
C>     ------------------------------------------------------- --------
C>     ASIN   ATAN2                                            SYSTEM
C>
C>   REMARKS:
C>
C>   1. W1 AND W2 ARE USED TO STORE SETS OF CONSTANTS WHICH ARE
C>   REUSABLE FOR REPEATED CALLS TO THE SUBROUTINE. IF THEY ARE
C>   OVER WRITTEN BY THE USER, A WARNING MESSAGE WILL BE PRINTED
C>   AND W1 AND W2 WILL BE RECOMPUTED.
C>
C>   2. WIND COMPONENTS ARE NOT ROTATED TO THE 65*65 GRID ORIENTATION
C>   AFTER INTERPOLATION. YOU MAY USE W3FC08 TO DO THIS.
C>
C>   3. THE GRID POINTS VALUES ON THE EQUATOR HAVE BEEN EXTRAPOLATED
C>   OUTWARD TO ALL THE GRID POINTS OUTSIDE THE EQUATOR ON THE 65*65
C>   GRID (ABOUT 1100 POINTS).
C>
C>   4. YOU SHOULD USE THE CRAY VECTORIZED VERSION W3FT05V ON THE CRAY
C>   IT HAS 3 PARAMETERS IN THE CALL, RUNS ABOUT 10 TIMES FASTER. USES
C>   MORE MEMORY.
C>
C> ATTRIBUTES:
C>   LANGUAGE: CRAY CFT77 FORTRAN
C>   MACHINE:  CRAY Y-MP8/832
C>
      SUBROUTINE W3FT05(ALOLA,APOLA,W1,W2,LINEAR)
C
       REAL            ALOLA(145,37)
       REAL            APOLA(4225)
       REAL            ERAS(4)
       REAL            SAVEW1(10)
       REAL            SAVEW2(10)
       REAL            W1(4225)
       REAL            W2(4225)
C
       INTEGER         JY(4)
       INTEGER         OUT
C
       LOGICAL         LIN
C
       SAVE
C
       DATA  DEGPRD/57.2957795/
       DATA  EARTHR/6371.2/
       DATA  ISWT  /0/
       DATA  OUT   /6/
C
 4000  FORMAT ( 52H *** WARNING , W1 OR W2 SCRATCH FILES OVER WRITTEN ,,
     &          43H I WILL RESTORE THEM , BURNING UP CPU TIME,,
     &          14H IN W3FT05 ***)
C
         LIN = .FALSE.
         IF (LINEAR.EQ.1) LIN = .TRUE.
C
         IF  (ISWT.EQ.0)  GO TO  300
C
C        TEST W1 AND W2 TO SEE IF THEY WERE WRITTEN OVER
C
         DO 100  KK=1,10
           IF (SAVEW1(KK).NE.W1(KK)) GO TO  200
           IF (SAVEW2(KK).NE.W2(KK)) GO TO  200
  100    CONTINUE
         GOTO  1000
C
  200    CONTINUE
         WRITE (OUT,4000)
C
  300    CONTINUE
         DEG   = 2.5
         NN    = 0
         XMESH = 381.0
         GI2   = (1.86603*EARTHR) / XMESH
         GI2   = GI2 * GI2
C
C        DO LOOP 800 PUTS SUBROUTINE W3FB01 IN LINE
C
         DO  800  J = 1,65
           XJ  = J - 33
           XJ2 = XJ * XJ
           DO  800  I=1,65
             XI = I - 33
             R2 = XI*XI + XJ2
             IF  (R2.NE.0.0)  GO TO  400
             WLON = 0.0
             XLAT = 90.0
             GO TO  700
 400         CONTINUE
             XLONG = DEGPRD * ATAN2(XJ,XI)
             IF (XLONG.GE.0.0)  GO TO 500
             WLON  = -10.0 - XLONG
             IF (WLON.LT.0.0)  WLON = WLON + 360.0
             GO TO  600
C
 500         CONTINUE
             WLON = 350.0 - XLONG
 600         CONTINUE
             XLAT = ASIN((GI2-R2)/(GI2+R2))*DEGPRD
 700         CONTINUE
             IF  (WLON.GT.360.0)  WLON = WLON - 360.0
             IF  (WLON.LT.0.0)   WLON = WLON + 360.0
             NN     = NN + 1
             W1(NN) = ( 360.0 - WLON ) / DEG + 1.0
             W2(NN) = XLAT / DEG + 1.0
 800       CONTINUE
C
         DO 900  KK = 1,10
           SAVEW1(KK) = W1(KK)
           SAVEW2(KK) = W2(KK)
 900     CONTINUE
C
         ISWT = 1
C
 1000    CONTINUE
C
         DO  2100  KK = 1,4225
           I     = W1(KK)
           J     = W2(KK)
           FI    = I
           FJ    = J
           XDELI = W1(KK) - FI
           XDELJ = W2(KK) - FJ
           IP1   = I + 1
           JY(3) = J + 1
           JY(2) = J
           IF (LIN)  GO TO 1100
           IP2   = I + 2
           IM1   = I - 1
           JY(4) = J + 2
           JY(1) = J - 1
           XI2TM = XDELI * (XDELI-1.) * 0.25
           XJ2TM = XDELJ * (XDELJ-1.) * 0.25
C
 1100    CONTINUE
           IF ((I.LT.2).OR.(J.LT.2))    GO TO  1200
           IF ((I.GT.142).OR.(J.GT.34)) GO TO  1200
C
C     QUADRATIC (LINEAR TOO) OK W/O FURTHER ADO SO GO TO 1700
C
           GO TO  1700
C
 1200    CONTINUE
           IF (I.EQ.1)   GO TO  1300
           IF (I.EQ.144) GO TO 1400
           IP2 = I + 2
           IM1 = I - 1
           GO TO  1500
C
 1300    CONTINUE
           IP2 = 3
           IM1 = 144
           GO TO   1500
C
 1400    CONTINUE
           IP2 = 2
           IM1 = 143
C
 1500   CONTINUE
          IP1 = I + 1
          IF (LIN)  GO TO 1600
          IF ((J.LT.2).OR.(J.GE.36))  XJ2TM=0.
C.....DO NOT ALLOW POINT OFF GRID
          IF (IP2.LT.1)   IP2 = 1
          IF (IM1.LT.1)   IM1 = 1
          IF (IP2.GT.145) IP2 = 145
          IF (IM1.GT.145) IM1 = 145
C
 1600   CONTINUE
C.....DO NOT ALLOW POINT OFF GRID
          IF (I.LT.1)     I   = 1
          IF (IP1.LT.1)   IP1 = 1
          IF (I.GT.145)   I   = 145
          IF (IP1.GT.145) IP1 = 145
C
 1700    CONTINUE
         IF (.NOT.LIN)  GO TO  1900
C
C        LINEAR INTERPLOATION
C
         DO 1800 K = 2,3
           J1 = JY(K)
           IF  (J1.LT.1)  J1 = 1
           IF  (J1.GT.37) J1 = 37
           ERAS(K) = (ALOLA(IP1,J1) - ALOLA(I,J1)) * XDELI + ALOLA(I,J1)
 1800    CONTINUE
C
           APOLA(KK) = ERAS(2) + (ERAS(3) - ERAS(2)) * XDELJ
           GO TO  2100
C
 1900    CONTINUE
C
C        QUADRATIC INTERPOLATION
C
         DO 2000 K = 1,4
           J1 = JY(K)
C.....DO NOT ALLOW POINT OFF GRID
           IF (J1.LT.1) J1 = 1
           IF (J1.GT.37) J1 = 37
           ERAS(K) = (ALOLA(IP1,J1)-ALOLA(I,J1))*XDELI+ALOLA(I,J1)+
     &               (ALOLA(IM1,J1)-ALOLA(I,J1)-ALOLA(IP1,J1)+
     &                ALOLA(IP2,J1))*XI2TM
 2000    CONTINUE
C
         APOLA(KK) = ERAS(2)+(ERAS(3)-ERAS(2))*XDELJ+(ERAS(1)-
     &               ERAS(2)-ERAS(3)+ERAS(4)) * XJ2TM
C
 2100    CONTINUE
C
C        SET POLE POINT , WMO STANDARD FOR U OR V
C
         APOLA(2113) = ALOLA(73,37)
C
         RETURN
       END
