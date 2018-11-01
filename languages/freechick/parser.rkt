#lang brag

fc-program: (fc-line)+

@fc-line: fc-map | draw-block | action-block | win-block | interactions-block | /NEWLINE-TOKEN

fc-map: /START-MAP-TOKEN /NEWLINE-TOKEN (map-row)+ /END-MAP-TOKEN

map-row: (MAP-CHAR-TOKEN)+ /NEWLINE-TOKEN

draw-block: /DRAW-TOKEN /NEWLINE-TOKEN (draw-rule)+

draw-rule: ID /RULE-RESULT-TOKEN STRING-TOKEN /(NEWLINE-TOKEN)?

action-block: /ACTION-TOKEN ID /":" /NEWLINE-TOKEN (action-rule)+

action-rule: STRING-TOKEN /RULE-RESULT-TOKEN /"(" NUM-TOKEN /"," NUM-TOKEN /")" /(NEWLINE-TOKEN)?

interactions-block: /INTERACTIONS-TOKEN /NEWLINE-TOKEN (interaction-rule)+

interaction-rule: (ID PUSH-TOKEN ID | ID STOP-TOKEN ID) /(NEWLINE-TOKEN)?

win-block: /WIN-TOKEN /NEWLINE-TOKEN (win-rule)+

win-rule: ID EQUALS-TOKEN ID



