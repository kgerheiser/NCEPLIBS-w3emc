C> @file
C
C> SUBROUTINE: W3FT211   CONVERT (361,91) GRID TO (93,65) LAMBERT GRID
C>   AUTHOR:  JONES,R.E.        ORG:  W342         DATE: 94-05-18
C>
C> ABSTRACT:  CONVERT A NORTHERN HEMISPHERE 1.0 DEGREE LAT.,LON. 361 BY
C>   91 GRID TO A LAMBERT CONFORMAL 93 BY 65 AWIPS GRIB 211.
C>
C> PROGRAM HISTORY LOG:
C>   94-05-18  R.E.JONES  
C>
C> USAGE:  CALL W3FT211(ALOLA,ALAMB,INTERP)
C>
C>   INPUT ARGUMENTS:  ALOLA  - 361*91 GRID 1.0 DEG. LAT,LON GRID N. HEMI.
C>                              32851 POINT GRID. 360 * 181 ONE DEGREE
C>                              GRIB GRID 3 WAS FLIPPED, GREENWISH ADDED
C>                              TO RIGHT SIDE AND CUT TO 361 * 91.  
C>                     INTERP - 1 LINEAR INTERPOLATION , NE.1 BIQUADRATIC
C>
C>   INPUT FILES:  NONE
C>
C>   OUTPUT ARGUMENTS: ALAMB  - 93*65 REGIONAL - CONUS
C>                              (LAMBERT CONFORMAL). 6045 POINT GRID 
C>                              IS AWIPS GRID TYPE 211
C>
C>   OUTPUT FILES: ERROR MESSAGE TO FORTRAN OUTPUT FILE
C>
C>   WARNINGS:
C>
C>   1. W1 AND W2 ARE USED TO STORE SETS OF CONSTANTS WHICH ARE
C>   REUSABLE FOR REPEATED CALLS TO THE SUBROUTINE. 11 OTHER ARRAY
C>   ARE SAVED AND REUSED ON THE NEXT CALL.
C>
C>   2. WIND COMPONENTS ARE NOT ROTATED TO THE 93*65 GRID ORIENTATION
C>   AFTER INTERPOLATION. YOU MAY USE W3FC08 TO DO THIS.
C>
C>   RETURN CONDITIONS: NORMAL SUBROUTINE EXIT
C>
C>   SUBPROGRAMS CALLED:
C>     UNIQUE :  NONE
C>
C>     LIBRARY:  W3FB12
C>
C> ATTRIBUTES:
C>   LANGUAGE: CRAY CFT77 FORTRAN
C>   MACHINE:  CRAY C916-128, CRAY Y-MP8/864, CRAY Y-MP EL2/256
C>
      SUBROUTINE W3FT211(ALOLA,ALAMB,INTERP)
C
C
       PARAMETER   (NPTS=6045,II=93,JJ=65)
       PARAMETER   (ALATAN=25.000)
       PARAMETER   (PI=3.1416)
       PARAMETER   (DX=81270.500)
       PARAMETER   (ALAT1=12.190)
       PARAMETER   (ELON1=226.541)
       PARAMETER   (ELONV=265.000)
       PARAMETER   (III=361,JJJ=91)
C
       REAL        ALOLA(III,JJJ)
       REAL        ALAMB(NPTS)
       REAL        W1(NPTS),    W2(NPTS),   ERAS(NPTS,4)
       REAL        XDELI(NPTS), XDELJ(NPTS)
       REAL        XI2TM(NPTS), XJ2TM(NPTS)
C
       INTEGER     IV(NPTS),      JV(NPTS),    JY(NPTS,4)
       INTEGER     IM1(NPTS),     IP1(NPTS),   IP2(NPTS)
C
       LOGICAL     LIN
C
       SAVE
C
       DATA  ISWT  /0/
       DATA  INTRPO/99/
C
       LIN = .FALSE.
       IF (INTERP.EQ.1) LIN = .TRUE.
C
       IF (ISWT.EQ.1) GO TO 900
c      print *,'iswt = ',iswt
       N  = 0
       DO J = 1,JJ
         DO I = 1,II
           XJ = J
           XI = I
           CALL W3FB12(XI,XJ,ALAT1,ELON1,DX,ELONV,ALATAN,ALAT,
     &     ELON,IERR)
           N     = N    + 1
           W1(N) = ELON + 1.0 
           W2(N) = ALAT + 1.0
         END DO
       END DO
C
       ISWT   = 1
       INTRPO = INTERP
       GO TO 1000 
C
C     AFTER THE 1ST CALL TO W3FT211 TEST INTERP, IF IT HAS
C     CHANGED RECOMPUTE SOME CONSTANTS
C
 900   CONTINUE
         IF (INTERP.EQ.INTRPO) GO TO 2100
         INTRPO = INTERP
C
 1000 CONTINUE
        DO 1100 K = 1,NPTS
          IV(K)    = W1(K)
          JV(K)    = W2(K)
          XDELI(K) = W1(K) - IV(K)
          XDELJ(K) = W2(K) - JV(K)
          IP1(K)   = IV(K) + 1
          JY(K,3)  = JV(K) + 1
          JY(K,2)  = JV(K)
 1100   CONTINUE
C
      IF (LIN) GO TO 2100
C
      DO 1200 K = 1,NPTS
        IP2(K)   = IV(K) + 2
        IM1(K)   = IV(K) - 1
        JY(K,1)  = JV(K) - 1
        JY(K,4)  = JV(K) + 2
        XI2TM(K) = XDELI(K) * (XDELI(K) - 1.0) * .25
        XJ2TM(K) = XDELJ(K) * (XDELJ(K) - 1.0) * .25
 1200 CONTINUE
C
 2100 CONTINUE
      IF (LIN) THEN
C
C     LINEAR INTERPOLATION
C
      DO 2200 KK = 1,NPTS
        ERAS(KK,2) = (ALOLA(IP1(KK),JY(KK,2))-ALOLA(IV(KK),JY(KK,2)))
     &             * XDELI(KK) + ALOLA(IV(KK),JY(KK,2))
        ERAS(KK,3) = (ALOLA(IP1(KK),JY(KK,3))-ALOLA(IV(KK),JY(KK,3)))
     &             * XDELI(KK) + ALOLA(IV(KK),JY(KK,3))
 2200 CONTINUE
C
      DO 2300 KK = 1,NPTS
        ALAMB(KK) = ERAS(KK,2) + (ERAS(KK,3) - ERAS(KK,2))
     &            * XDELJ(KK)
 2300 CONTINUE
C
      ELSE
C
C     QUADRATIC INTERPOLATION
C
      DO 2400 KK = 1,NPTS
        ERAS(KK,1)=(ALOLA(IP1(KK),JY(KK,1))-ALOLA(IV(KK),JY(KK,1)))
     &            * XDELI(KK) + ALOLA(IV(KK),JY(KK,1)) +
     &            ( ALOLA(IM1(KK),JY(KK,1)) - ALOLA(IV(KK),JY(KK,1))
     &            - ALOLA(IP1(KK),JY(KK,1))+ALOLA(IP2(KK),JY(KK,1)))
     &            * XI2TM(KK)
        ERAS(KK,2)=(ALOLA(IP1(KK),JY(KK,2))-ALOLA(IV(KK),JY(KK,2)))
     &            * XDELI(KK) + ALOLA(IV(KK),JY(KK,2)) +
     &            ( ALOLA(IM1(KK),JY(KK,2)) - ALOLA(IV(KK),JY(KK,2))
     &            - ALOLA(IP1(KK),JY(KK,2))+ALOLA(IP2(KK),JY(KK,2)))
     &            * XI2TM(KK)
        ERAS(KK,3)=(ALOLA(IP1(KK),JY(KK,3))-ALOLA(IV(KK),JY(KK,3)))
     &            * XDELI(KK) + ALOLA(IV(KK),JY(KK,3)) +
     &            ( ALOLA(IM1(KK),JY(KK,3)) - ALOLA(IV(KK),JY(KK,3))
     &            - ALOLA(IP1(KK),JY(KK,3))+ALOLA(IP2(KK),JY(KK,3)))
     &            * XI2TM(KK)
        ERAS(KK,4)=(ALOLA(IP1(KK),JY(KK,4))-ALOLA(IV(KK),JY(KK,4)))
     &            * XDELI(KK) + ALOLA(IV(KK),JY(KK,4)) +
     &            ( ALOLA(IM1(KK),JY(KK,4)) - ALOLA(IV(KK),JY(KK,4))
     &            - ALOLA(IP1(KK),JY(KK,4))+ALOLA(IP2(KK),JY(KK,4)))
     &            * XI2TM(KK)
 2400      CONTINUE
C
       DO 2500 KK = 1,NPTS
         ALAMB(KK) = ERAS(KK,2) + (ERAS(KK,3) - ERAS(KK,2))
     &             * XDELJ(KK)  + (ERAS(KK,1) - ERAS(KK,2)
     &             - ERAS(KK,3) + ERAS(KK,4)) * XJ2TM(KK)
 2500  CONTINUE
C
      ENDIF
C
      RETURN
      END
