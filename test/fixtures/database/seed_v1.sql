-- Synthetic values only; never loaded by product startup.
INSERT INTO skills(id,name,kind,icon_key,accent_key,created_at_utc,updated_at_utc)
VALUES('11111111-1111-4111-8111-111111111111','Synthetic typing','typing','practice','brand',1793088000,1793088000);
INSERT INTO exercises(id,skill_id,title,created_at_utc,updated_at_utc)
VALUES('22222222-2222-4222-8222-222222222222','11111111-1111-4111-8111-111111111111','Synthetic exercise',1793088000,1793088000);
INSERT INTO sessions(id,skill_id,ended_at_utc,entry_mode,manual_intent,status,created_at_utc,updated_at_utc,note)
VALUES('33333333-3333-4333-8333-333333333333','11111111-1111-4111-8111-111111111111',1793088000,'manual','evidence_only','completed',1793088000,1793088000,'Synthetic prior-version journal');
INSERT INTO session_exercises(session_id,exercise_id,exercise_title_snapshot,ordinal)
VALUES('33333333-3333-4333-8333-333333333333','22222222-2222-4222-8222-222222222222','Synthetic exercise',0);
INSERT INTO metric_definitions(id,version,skill_id,label,unit_key,value_type,direction,source_hint)
VALUES('44444444-4444-4444-8444-444444444444',1,'11111111-1111-4111-8111-111111111111','Synthetic speed','wpm','numeric','up','manual');
INSERT INTO metric_readings(id,session_id,metric_definition_id,definition_version,numeric_value,source_type,measured_at_utc,created_at_utc)
VALUES('55555555-5555-4555-8555-555555555555','33333333-3333-4333-8333-333333333333','44444444-4444-4444-8444-444444444444',1,40,'self_reported',1793088000,1793088000);
INSERT INTO goals(id,skill_id,title,type,metric_definition_id,definition_version,target_value,target_unit,status,created_at_utc,updated_at_utc)
VALUES('66666666-6666-4666-8666-666666666666','11111111-1111-4111-8111-111111111111','Synthetic goal','threshold','44444444-4444-4444-8444-444444444444',1,60,'wpm','active',1793088000,1793088000);
INSERT INTO media_assets(id,session_id,kind,mime,byte_length,sha256,relative_path,capture_source,created_at_utc,storage_state)
VALUES('77777777-7777-4777-8777-777777777777','33333333-3333-4333-8333-333333333333','image','image/test-fixture',3,'039058c6f2c0cb492c533b0a4d14ef77cc0f78abccced5287d84a1a2011cfb81','media/99999999-9999-4999-8999-999999999999.blob','file_import',1793088000,'ready');
INSERT INTO reminders(id,skill_id,local_time_h_hmm,weekdays_bitset,iana_zone,message_id,updated_at_utc)
VALUES('88888888-8888-4888-8888-888888888888','11111111-1111-4111-8111-111111111111','08:30',127,'Asia/Manila','practice',1793088000);
INSERT INTO settings(key,value_json,updated_at_utc) VALUES('theme','"dark"',1793088000);
INSERT INTO data_migrations(version,completed_at_utc) VALUES(1,1793088000);
INSERT INTO export_history(id,created_at_utc,archive_schema,byte_length,outcome)
VALUES('synthetic-export',1793088000,1,1234,'success');
