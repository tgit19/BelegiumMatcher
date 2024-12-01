# Test files

## Valid

### An < Bn

```
;Person1;Person2
WG1;6;12
WG2;8;13
WG3;10;15
;;;
;WG1;WG2;WG3
Person1;10;10;8
Person2;11;12;7
```

### An > Bn

```
;Person1;Person2;Person3
WG1;6;12;18
WG2;8;13;7
;;;
;WG1;WG2
Person1;10;10
Person2;11;12
Person3;8;14
```

### quadratic_comma

```
,Person1,Person2
WG1,6,12
WG2,8,13
,,,
,WG1,WG2
Person1,10,10
Person2,11,12
```

### quadratic_semicolon

```
;Person1;Person2;Person3
WG1;6;12;18
WG2;8;13;7
WG3;10;15;12
;;;
;WG1;WG2;WG3
Person1;10;10;8
Person2;11;12;7
Person3;8;14;9
```

### sorted_names

```
;2.1;2.2;2.3;2.4;
Anna;5;9;11;12;
Henry;4;10;15;5;
Luisa;13;12;12;5;
Samuel;15;7;14;13;
Simon;14;3;1;0;
;;;;;
;Anna;Henry;Luisa;Samuel;Simon
2.1;7;7;13;15;7
2.2;12;12;3;1;6
2.3;2;5;13;14;4
2.4;7;15;1;6;10
```

### unsorted_names

```
;2.1;2.2;2.3;2.4;;
Samuel;15;7;14;13;
Simon;14;3;1;0;
Luisa;13;12;12;5;
Anna;5;9;11;12;
Henry;4;10;15;5;
;;;;;;;
;Samuel;Simon;Luisa;Anna;Henry;
2.1;15;7;13;7;7;
2.2;1;6;3;12;12;
2.3;14;4;13;2;5;
2.4;6;10;1;7;15;
```


## Invalid

### dimension_missmatch_A

```
;Person1
WG1;
WG2;
WG3;
;;;
;WG1;WG2;WG3
Person1;
Person2;
Person3;
```

### dimension_missmatch_B

```
;Person1;Person2;Person3
;;;
;WG1
Person1;
Person2;
Person3;
```

### missing_name_A

```
;Person1;Person2;Person
WG1;6;12;18
WG2;8;13;7
WG3;10;15;12
;;;
;WG1;WG2;WG3
Person1;10;10;8
Person2;11;12;7
Person3;8;14;9
```

### missing_name_B

```
;Person1;Person2;Person3
WG1;6;12;18
WG2;8;13;7
WG3;10;15;12
;;;
;WG1;WG2;WG
Person1;10;10;8
Person2;11;12;7
Person3;8;14;9
```

### multiple_empty_lines

```
;Person1;Person2;Person3
WG1;6;12;18
WG2;8;13;7
WG3;10;15;12
;;;
;WG1;WG2;WG3
;;;
Person1;10;10;8
Person2;11;12;7
Person3;8;14;9
;;;
```

### no_empty_line

```
;Person1;Person2;Person3
WG1;6;12;18
WG2;8;13;7
WG3;10;15;12

;WG1;WG2;WG3
Person1;10;10;8
Person2;11;12;7
Person3;8;14;9
```

### non_numeric

```
;Person1;Person2
WG1;6;A
WG2;8;13
;;;
;WG1;WG2
Person1;B;10
Person2;11;12
```

### to_small

```
;Person1
WG1;6
;;;
;WG1
Person1;10
```