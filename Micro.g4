grammar Micro;


@header {

  import java.io.*;
  import java.util.LinkedHashMap;
  import java.util.Stack;
  import java.util.Iterator;
  import java.util.LinkedList;

}


@members {
        
	// HASH TABLE FOR ALL (string, hash table for scopes)
	public static LinkedHashMap<String, LinkedHashMap<String, Object[]>> table_scope = new LinkedHashMap< String, LinkedHashMap<String, Object[]>>();
	
	// Current symbol for current scope (just a buffer)
	LinkedHashMap<String, Object[]> current_hash = new LinkedHashMap<String, Object[]>();

	//the string for current scope  (temp value, buffer value) 
	String scope_name = new String();

	

	// generate symbol table for each table, and add the table into the high hash_table

	public static LinkedHashMap gen_table_scope(String scope_name){
		// generate the scope table
		LinkedHashMap<String, Object[]> table = new LinkedHashMap<String, Object[]>();

		// put the table into the table_scope, the key is scope_name
		table_scope.put(scope_name, table);
		
		return table; // return the table for use. 
	}

	// Print all scopes names
	public static void print_table_scope(){
		LinkedHashMap<String, Object[]> cur = new LinkedHashMap<String, Object[]>();
		
		for (Iterator it =  table_scope.keySet().iterator();it.hasNext();)
			// outer loop for scope 
   		{
		    	Object key = it.next(); // get the key(scope name) in the table
		 
		    	System.out.println("Symbol table " + key);
 
			// inner loop for print the element 
			cur = table_scope.get(key); // get the table in current scope

			//System.out.println("\n\nfor debug in print SUB-TABLE\n table name is " + key +" \n variable name is: str\n" +"value and type of it is: " + cur.get("str")[1] +" " +cur.get("str")[0]+"\n\n" );
				

			for (Iterator he =  cur.keySet().iterator();he.hasNext();){
				Object key_in = he.next();
				//System.out.println(key_in + " = " + cur.get(key_in)[1]); 

				if(cur.get(key_in)[1] != null){ // if it is a string, then.......
					System.out.println("name " + key_in + " type " + cur.get(key_in)[0] + " value " + cur.get(key_in)[1] );

				}
				else{ // if it is an int or float then println......
					System.out.println("name " + key_in + " type " + cur.get(key_in)[0]);
				}
				
			}
		    
		}
	
	}

	// add "STRING" or "INT" or "FLOAT" into the table
	public static void add_symbol(LinkedHashMap table, String text,int type, Object value){

		// temp value for buffer Object[0] 		
		Object[] temp = new Object[2];
		if(table.containsKey(text)){ // if the table already the key, then error
			System.out.println("Error dual symbol, WTF!!!!!!");
			System.exit(1);
		}
		else{
			temp = symbol_gen(type,value);
			table.put(text, temp);
				//System.out.println("In add_symbol is temp[0] " + temp[0] + " temp[1] "+ temp[1]+ "\n\n");
				// test if the value is added into the sub-table ? added, yes
				/*
				for (Iterator it =  table.keySet().iterator();it.hasNext();)
				   {
				    Object key = it.next();
				    Object[] test_ha = new Object[2];
				    test_ha = (Object[]) table.get(key);
				   System.out.println( key+"=" + test_ha[0] + test_ha[1]);
				   }
				
				System.out.println("\n\n\n");
				*/
				
		}

	} 

	// generate the symbol element  TYPE(0) == STRING, TYPE(1) == FLOAT, TYPE(2) == INT, TYPE(3) == VOID
	public static Object[] symbol_gen(int type, Object value){
		Object[] temp = new Object[2];
		switch(type){
			case 0:     //string
				temp[0] = new String("STRING");
				if(value == null){
				     temp[1] = null;
				}
				else{
					temp[1] = (String)value;
				}
				break; 		
				
			case 1:				// float
				temp[0] = new String("FLOAT");
				if(value == null){
				     temp[1] = null;
				}
				else{
					temp[1] = (String)value;
				}
				break;

			case 2:				// int
				temp[0] = new String("INT");
				if(value == null){
				     temp[1] = null;
				}
				else{
					temp[1] = (String)value;
				}
				break;

			case 3:			      // void
				temp[0] = new String("VOID");
				if(value == null){
				     temp[1] = null;
				}
				else{
					temp[1] = (String)value;
				}
				break;

			default:
				System.out.println( " Wrong type");
				System.exit(1);		
				




		}

		return temp;
	}


}







/* Program */
program           : PROGRAM {scope_name = "GLOBAL"; current_hash = gen_table_scope(scope_name); } id BEGIN pgm_body END{print_table_scope();}; 
id                : IDENTIFIER;
pgm_body          : decl func_declarations;
/*decl		  : ( string_decl_list (decl?) | var_decl_list (decl?) )? ; */
decl		  : ( string_decl (string_decl_tail?) (decl?) | var_decl (var_decl_tail?) (decl?) )? |;


/* Global String Declaration */

string_decl       :  STRING id ':=' str ';'  { add_symbol(current_hash,$id.text,0,$str.text ); } ;  

str               : STRINGLITERAL                   ;
string_decl_tail  : string_decl (string_decl_tail?) ;



/* Variable Declaration */
/*var_decl_list     : var_decl (var_decl_tail?)     ; */
/* var_decl          : ( var_type id_list ';' )?     ; */

var_decl          :  var_type id_list ';'         ;
var_type	        : FLOAT | INT             ;
any_type          : var_type | VOID               ; 
id_list           : id id_tail                    ;
id_tail           : (',' id id_tail )?            ;
var_decl_tail     : var_decl (var_decl_tail?)     ;



/* Function Paramater List */
param_decl_list   : param_decl param_decl_tail             ;
param_decl        : var_type id                            ;
param_decl_tail   : ( ',' param_decl param_decl_tail )?    ;


/* Function Declarations */
func_declarations : func_decl (func_decl_tail?)  |                                           ;
func_decl         : FUNCTION any_type id '('(param_decl_list?)')' BEGIN func_body END  ;
func_decl_tail    : func_decl (func_decl_tail?) |                                             ;
func_body         : decl stmt_list                                                          ;



/* Statement List */
stmt_list         : ( stmt stmt_tail )?                                 ;
stmt_tail         : ( stmt stmt_tail )?                                 ;
stmt              : base_stmt | if_stmt | do_while_stmt                 ;
base_stmt         : assign_stmt | read_stmt | write_stmt | return_stmt  ;



/* Basic Statements */
assign_stmt       : assign_expr ';'                ;
assign_expr       : id ':=' expr                   ;
read_stmt         : READ '(' id_list ')' ';'       ;
write_stmt        : WRITE '(' id_list ')' ';'      ;
return_stmt       : RETURN expr ';'                ;



/* Expressions */
expr              : factor expr_tail                                            ;
expr_tail         : ( addop factor expr_tail  )?                                ;
factor            : postfix_expr factor_tail                                    ;
factor_tail       : ( mulop postfix_expr factor_tail )?                         ;
postfix_expr      : primary | call_expr                                         ;
call_expr         : id '(' (expr_list?) ')'                                     ;
expr_list         : expr expr_list_tail                                         ;
expr_list_tail    : (',' expr expr_list_tail )?                                 ;
primary           : ( '('expr')' ) | id | INTLITERAL | FLOATLITERAL             ;
addop             : '+' | '-'                                                   ;
mulop             : '*' | '/'                                                   ;


/* Complex Statements and Condition */ 
if_stmt           : IF '(' cond ')' (decl?) stmt_list else_part ENDIF           ; 
else_part         : (   ELSIF '(' cond ')' (decl?) stmt_list else_part   )?     ;
cond              : (expr compop expr) | TRUE | FALSE                           ;
compop            : '<' | '>' | '=' | '!=' | '<=' | '>='                        ;


/* ECE 468 students use this version of do_while_stmt */
do_while_stmt       : DO (decl?) stmt_list WHILE '(' cond ')' ';'               ;



	
//KEYWORD : PROGRAM|BEGIN|END|FUNCTION|READ|WRITE|IF|ELSIF|ENDIF|DO|WHILE|CONTINUE|BREAK|RETURN|INT|VOID|STRING|FLOAT|TRUE|FALSE;

PROGRAM:'PROGRAM';

BEGIN:'BEGIN';
END:'END';
FUNCTION:'FUNCTION';
READ:'READ';
WRITE:'WRITE';
IF:'IF';
ELSIF:'ELSIF';
ENDIF:'ENDIF';
DO:'DO';
WHILE:'WHILE';
CONTINUE:'CONTINUE';
BREAK:'BREAK';
RETURN:'RETURN';
INT:'INT';
VOID:'VOID';
STRING:'STRING';
FLOAT:'FLOAT';
TRUE:'TRUE';
FALSE:'FALSE';



IDENTIFIER : ('a'..'z'|'A'..'Z')('a'..'z'|'A'..'Z'|'0'..'9')*;
INTLITERAL : ('0'..'9')+;
FLOATLITERAL : ('0'..'9')*'.'('0'..'9')+;
STRINGLITERAL : '"'(~('\t'|'\n'|'\r'|'"'))*'"';
OPERATOR : (':='|'+'|'-'|'*'|'/'|'='|'!='|'<'|'>'|'('|')'|';'|','|'<='|'>=');
COMMENT : ( '--' ~[\r\n]* '\r'? '\n' | '/*' .*? '*/' ) -> skip;
WS : (' '|'\t'|'\f'|'\r'|'\n') ->  skip;
	









