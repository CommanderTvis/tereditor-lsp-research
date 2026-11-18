# Get JsonObject from google.protobuf.Struct

# Problem solved by the feature
Currently the easiest way to convert a protobuf Struct to a JsonObject is to first print it to String using JsonFormat.printer().print() and the read the String using gson.fromJson method. Something like this:
```
String jsonString = JsonFormat.printer().omittingInsignificantWhitespace().print(struct);
JsonObject jsonObject = gson.FromJson(jsonString, JsonObject.class);
```

This is slightly inefficient in my opinion since there is a two step conversion and can be optimized to have a single conversion from Struct to JsonObject

# Feature description
Please, is it possible to implement a method fromProtobufStruct (or fromStruct) that converts a Struct to a JsonObject?
