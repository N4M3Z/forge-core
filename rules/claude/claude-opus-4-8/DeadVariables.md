When generating code, verify each variable is read by something. A variable that is assigned but never consumed downstream is dead weight -- delete it before committing.
