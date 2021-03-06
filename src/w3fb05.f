C> @file
C
C> SUBPROGRAM: W3FB05         GRID COORDINATES TO LATITUDE, LONGITUDE
C>   AUTHOR: JONES,R.E.       ORG: W345       DATE: 86-07-17
C>
C> ABSTRACT: CONVERTS THE COORDINATES OF A LOCATION FROM THE GRID(I,J)
C>   COORDINATE SYSTEM OVERLAID ON THE POLAR STEREOGRAPHIC MAP PROJEC-
C>   TION TRUE AT 60 DEGREES N OR S LATITUDE TO THE NATURAL COORDINATE
C>   SYSTEM OF LATITUDE/LONGITUDE ON THE EARTH. W3FB05 IS THE REVERSE
C>   OF W3FB04.
C>
C> PROGRAM HISTORY LOG:
C>   86-07-17  R.E.JONES
C>   89-11-01  R.E.JONES   CHANGE TO CRAY CFT77 FORTRAN
C>
C> USAGE:  CALL W3FB05 (XI, XJ, XMESHL, ORIENT, ALAT, ALONG)
C>
C>   INPUT VARIABLES:
C>     NAMES  INTERFACE DESCRIPTION OF VARIABLES AND TYPES
C>     ------ --------- -----------------------------------------------
C>     XI     ARG LIST  I OF THE POINT RELATIVE TO THE NORTH OR S. POLE
C>     XJ     ARG LIST  J OF THE POINT RELATIVE TO THE NORTH OR S. POLE
C>     XMESHL ARG LIST  MESH LENGTH OF GRID IN KM AT 60 DEGREES(<0 IF SH)
C>                   (190.5 LFM GRID, 381.0 NH PE GRID,-381.0 SH PE GRID)
C>     ORIENT ARG LIST  ORIENTATION WEST LONGITUDE OF THE GRID
C>                    (105.0 LFM GRID, 80.0 NH PE GRID, 260.0 SH PE GRID)
C>
C>   OUTPUT VARIABLES:
C>     NAMES  INTERFACE DESCRIPTION OF VARIABLES AND TYPES
C>     ------ --------- -----------------------------------------------
C>     ALAT   ARG LIST  LATITUDE IN DEGREES  (<0 IF SH)
C>     ALONG  ARG LIST  WEST LONGITUDE IN DEGREES
C>
C>   SUBPROGRAMS CALLED:
C>     NAMES                                                   LIBRARY
C>     ------------------------------------------------------- --------
C>     ASIN   ATAN2                                            SYSLIB
C>
C>   REMARKS: ALL PARAMETERS IN THE CALLING STATEMENT MUST BE
C>     REAL. THE RANGE OF ALLOWABLE LATITUDES IS FROM A POLE TO
C>     30 DEGREES INTO THE OPPOSITE HEMISPHERE.
C>     THE GRID USED IN THIS SUBROUTINE HAS ITS ORIGIN (I=0,J=0)
C>     AT THE POLE, SO IF THE USER'S GRID HAS ITS ORIGIN AT A POINT
C>     OTHER THAN A POLE, A TRANSLATION IS REQUIRED TO GET I AND J FOR
C>     INPUT INTO W3FB05. THE SUBROUTINE GRID IS ORIENTED SO THAT
C>     GRIDLINES OF I=CONSTANT ARE PARALLEL TO A WEST LONGITUDE SUP-
C>     PLIED BY THE USER. THE EARTH'S RADIUS IS TAKEN TO BE 6371.2 KM.
C>
C>   WARNING: THIS CODE WILL NOT VECTORIZE, IT IS NORMALY USED IN A
C>            DOUBLE DO LOOP WITH W3FT01, W3FT00, ETC. TO VECTORIZE IT,
C>            PUT IT IN LINE, PUT W3FT01, W3FT00, ETC. IN LINE.
C>
C>   LANGUAGE: CRAY CFT77 FORTRAN
C>   MACHINE:  CRAY Y-MP8/832
C>
      SUBROUTINE W3FB05(XI,XJ,XMESHL,ORIENT,ALAT,ALONG)
C
      DATA  DEGPRD/57.2957795/
      DATA  EARTHR/6371.2/
C
      GI2   = ((1.86603 * EARTHR) / (XMESHL))**2
      R2    = XI * XI + XJ * XJ
C
      IF (R2.EQ.0.0) THEN
        ALONG = 0.0
        ALAT  = 90.0
        IF (XMESHL.LT.0.0) ALAT = -ALAT
        RETURN
      ELSE
        ALAT  = ASIN((GI2 - R2) / (GI2 + R2)) * DEGPRD
        ANGLE = DEGPRD * ATAN2(XJ,XI)
        IF (ANGLE.LT.0.0) ANGLE = ANGLE + 360.0
      ENDIF
C
      IF (XMESHL.GE.0.0) THEN
        ALONG = 270.0 + ORIENT - ANGLE
C
      ELSE
C
        ALONG = ANGLE + ORIENT - 270.0
        ALAT  = -(ALAT)
      ENDIF
C
      IF (ALONG.LT.0.0)   ALONG = ALONG + 360.0
      IF (ALONG.GE.360.0) ALONG = ALONG - 360.0
C
      RETURN
C
      END
