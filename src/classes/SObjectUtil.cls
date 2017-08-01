public class SObjectUtil {
    private static Set<String> disabledTriggers;

    /**
     * @description Determine if trigger is enabled or disabled in current transaction
     */
    public static Boolean isTriggerEnabled(Schema.sObjectType soType) {
        return (disabledTriggers==null || (!disabledTriggers.contains('ALL') && !disabledTriggers.contains(soType.getDescribe().getName())));
    }

    /**
     * @description Turn trigger on/off for specific sObject in current transaction
     */
    public static Boolean switchTrigger(Schema.sObjectType soType, Boolean enable) {
        return switchTrigger(soType.getDescribe().getName(), enable);
    }

    /**
     * @description Turn trigger on/off for all sObjects in current transaction
     */
    public static Boolean switchTrigger(Boolean enable) {
        return switchTrigger('ALL', enable);
    }

    /**
     * @description Turn trigger on/off for specific mode (All sObjects or specific sObject) in current transaction
     */
    public static Boolean switchTrigger(String mode, Boolean enable) {
        Boolean prevValue = disabledTriggers==null || !disabledTriggers.contains(mode);

        if(enable && disabledTriggers!=null) {
            disabledTriggers.remove(mode);
        } else if(!enable) {
            if(disabledTriggers==null) {
                disabledTriggers = new Set<String>();
            }

            disabledTriggers.add(mode);
        }

        return prevValue;
    }


    public static void updateExternalId(List<SObject> recs, SObjectField extIdField, SObjectField extIdFormulaField) {
        for(SObject rec : recs) {
            rec.put(String.valueOf(extIdField), rec.get(String.valueOf(extIdFormulaField)));
        }
    }

    public static void blockDelete(List<SObject> recs) {
        for(SObject rec : recs) {
            rec.addError('Delete not allowed');
        }
    }
}