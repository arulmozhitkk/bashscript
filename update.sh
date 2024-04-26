getGraphApiId(){

apiId=$(aws appsync  list-graphql-apis --query "graphqlApis[?name=='demo-people-api_appsync'] |[0].apiId"  --output text)

echo "API ID: $apiId"

dataSourceName=$(aws appsync  list-data-sources --api-id $apiId  --query "dataSources[:1] |[0].name"  --output text)

echo "Data Source Name $dataSourceName"

echo "Update Resolvers"

resolverDirectory="/d/Projects/AppSync/PIX/scripts/resolvers"
functionDirectory="/d/Projects/AppSync/PIX/scripts/functions"

for file in "${resolverDirectory}/"*;
do 

filename=$(basename -- "$file")
IFS='.' read -r -a fieldArr <<< "$filename"
fieldType=${fieldArr[0]}
fieldName=${fieldArr[1]}

code=$(cat $file)

echo "Resolver update for type:$fieldType field:$fieldName"
resolverResponse=$(aws appsync update-resolver --api-id $apiId --type-name $fieldType --field-name $fieldName --data-source-name $dataSourceName --code "$code" --runtime name="APPSYNC_JS",runtimeVersion="1.0.0")
 
echo $resolverResponse

done

#Update Functions
echo "Update function"

for fnfile in "${functionDirectory}/"*;
do 

fnfilename=$(basename -- "$fnfile")
IFS='.' read -r -a fnfieldArr <<< "$fnfilename"
fnName=${fnfieldArr[0]}

fncode=$(cat $fnfile)

functionId=$(aws appsync  list-functions --api-id $apiId --query "functions[?name=='$fnName'] |[0].functionId"  --output text)

echo "Function ID $functionId"

echo "Update function $fnName"
functionResponse=$(aws appsync update-function --api-id $apiId --name $fnName --function-id $functionId --data-source-name $dataSourceName --code "$fncode" --runtime name="APPSYNC_JS",runtimeVersion="1.0.0")
 
echo $functionResponse

done



}
getGraphApiId

