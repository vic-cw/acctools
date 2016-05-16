var csvRedQuery = 
  {
    "label": "Query CSV",
    "sql": "SELECT F1 FROM CSV ",
    "args": [ "" ],
    "query" : ""
  }
;
var csvRedTable = [ {
			"name" : "CSV",
			"label" : "Query Builder",
			"columns" : [ {	"name" : "","label" : "","type" : "STRING",	"size" : 80	} ],
			fks : []
		} ]
;
function csvCreateQueryUI()
{
    if(document.getElementById('rqb'))document.getElementById('rqb').innerHTML="";
    csvRedTable[0].columns.length = 0;
    for (k = 0; k < CSV.maxColumnsFound; k++) {
        csvRedTable[0].columns.push({"name" : "f"+ (k+1),"label" : "Field " + (k+1),"type" : "STRING", "size" : 80 });
    }
    RedQueryBuilderFactory.create({
        meta: {
            tables: csvRedTable,

            types: [{
                "name": "STRING",
                "editor": "TEXT",
                "operators": [
			{
			    "name": "==",
			    "label": "equal",
			    "cardinality": "ONE"
			},
			{
			    "name": "!=",
			    "label": "not equal",
			    "cardinality": "ONE"
			},
			{
			    "name": "<",
			    "label": "less than",
			    "cardinality": "ONE"
			},
			{
			    "name": "<=",
			    "label": "less than or equal",
			    "cardinality": "ONE"
			},
			{
			    "name": ">",
			    "label": "greater than",
			    "cardinality": "ONE"
			},
			{
			    "name": ">=",
			    "label": "greater than or equal",
			    "cardinality": "ONE"
			}
			]
            }, {
                "name": "DATE",
                "editor": "DATE",
                "operators": [{
                    "name": "=",
                    "label": "equal",
                    "cardinality": "ONE"
                }, {
                    "name": "!=",
                    "label": "not equal",
                    "cardinality": "ONE"
                }, {
                    "name": "<",
                    "label": "before",
                    "cardinality": "ONE"
                }, {
                    "name": ">",
                    "label": "after",
                    "cardinality": "ONE"
                }]
            }, {
                "name": "REF",
                "editor": "SELECT",
                "operators": [{
                    "name": "IN",
                    "label": "any of",
                    "cardinality": "MULTI"
                }]
            }]
        },
        onSqlChange: function (sql, args) {
            var out = sql;
            var pat;
            out = out.replace(/ AND /g, " && ").replace(/ OR /g, " || ");
            for (var f = 1; f <= CSV.maxColumnsFound; f++) {
                pat = new RegExp('"f' + f + '"', "gi");
                out = out.replace(pat, 'f' + f);
            } var v = "";
            for (var k in args) {
                // either treat literal as numeric or string
                if (!args[k]) v = '""';
                else {
                    v = (args[k] + "").replace(/\t/g, "\\t").replace(/\\/g, "\\\\").replace(/\"/g, "\\\"").replace(/\n/g, "\\n").replace(/\r/g, "\\r");
                    if (!isNaN(v) && CSV.statsCnt[k] && (CSV.statsCnt[k].fieldType == "N" || CSV.statsCnt[k].fieldType == "I")) {
                        v = '' + v + '';
                    } 
                    else v = '"' + v + '"';
                }
                out = out.replace("?", v);
            }
            out = out.substring(out.indexOf(csvRedTable[0].name + '"') + csvRedTable[0].name.length + 1 + "WHERE".length + 1);
            if (document.getElementById("debug")) document.getElementById("debug").value = out;
            csvRedQuery.query = "{" + out + " } " + "\n";
            //alert(csvRedQuery.query);
        },
        enumerate: function (request, response) {
            if (request.columnName == 'CATEGORY') {
                response([{ value: 'A', label: 'Small' }, { value: 'B', label: 'Medium'}]);
            } else {
                response([{ value: 'M', label: 'Male' }, { value: 'F', label: 'Female'}]);
            }
        },
        editors: [{
            name: 'DATE',
            format: 'dd.MM.yyyy'
        }]
	,
        from: { visible: false }
    }
    , csvRedQuery.sql
    , csvRedQuery.args
    )
};
