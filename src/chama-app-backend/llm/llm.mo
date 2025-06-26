import LLM "mo:llm";
import Text "mo:base/Text";
import Time "mo:base/Time";
import Debug "mo:base/Debug";
import Error "mo:base/Error";
import Int "mo:base/Int";

module {
    public type ChatRole = {
        #System;
        #User;
        #Assistant;
    };

    public type AIResponse = {
        content : Text;
        timestamp : Int;
        role : ChatRole;
    };

    // Shorter, more focused system prompt
    let SYSTEM_PROMPT : Text = 
        "You are a Chama assistant. Respond briefly and professionally. For greetings, provide a short welcome and ask about Chama interests. Keep responses under 100 words.";

    // Predefined responses for common scenarios
    let GREETING_RESPONSE : Text = 
        "Welcome to our Chama assistant! I'm here to help with your Chama group savings. Would you like to:\n 1. Learn about Chama basics\n 2. Get help with contributions\n 3. Understand member roles";

    public class LLMHelper() {
        // Normalize input text
        private func normalizeInput(text : Text) : Text {
            let trimmed = Text.trim(text, #char ' ');
            //Text.map(trimmed, Text.toLowercase)
        };

        // Check if input is a greeting
        private func isGreeting(text : Text) : Bool {
            let normalized = normalizeInput(text);
            switch(normalized) {
                case "hi" { true };
                case "hello" { true };
                case "hey" { true };
                case "greetings" { true };
                case _ { false };
            }
        };

        private func createSystemMessage() : LLM.ChatMessage {
            #system_({ content = SYSTEM_PROMPT })
        };

        private func createUserMessage(content : Text) : LLM.ChatMessage {
            #user({ content = normalizeInput(content) })
        };

        public func chat(userMessage : Text) : async AIResponse {
            try {
                // For greetings, return predefined response immediately
                if (isGreeting(userMessage)) {
                    return {
                        content = GREETING_RESPONSE;
                        timestamp = Time.now();
                        role = #Assistant;
                    };
                };

                let messages : [LLM.ChatMessage] = [
                    createSystemMessage(),
                    createUserMessage(userMessage)
                ];

                let llmInstance = LLM.chat(#Llama3_1_8B);
                let response = await llmInstance.withMessages(messages).send();

                switch (response.message.content) {
                    case (?text) {
                        {
                            content = text;
                            timestamp = Time.now();
                            role = #Assistant;
                        }
                    };
                    case null {
                        // Fallback response for null content
                        {
                            content = "I'm here to help with your Chama questions. Could you please be more specific about what you'd like to know?";
                            timestamp = Time.now();
                            role = #Assistant;
                        }
                    };
                };
            } catch(e) {
                Debug.print("Error in chat: " # Error.message(e));
                
                // Return a helpful response even when error occurs
                {
                    content = "I'm currently experiencing a brief delay. While I reset, here are some topics I can help with:\n" #
                             "1. Chama membership\n" #
                             "2. Contribution schedules\n" #
                             "3. Group savings strategies\n" #
                             "Please try asking about any of these topics.";
                    timestamp = Time.now();
                    role = #Assistant;
                }
            }
        };
    };
}