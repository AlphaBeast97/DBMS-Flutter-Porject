export function createMockCallProcedure(returnRows) {
  return async function callProcedure(name, params) {
    return returnRows;
  };
}

export function createMockCallProcedureMulti(resultSets) {
  return async function callProcedureMulti(name, params) {
    return resultSets;
  };
}
