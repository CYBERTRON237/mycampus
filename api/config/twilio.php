<?php
require_once __DIR__ . '/../../vendor/autoload.php';
use Twilio\Rest\Client;

class TwilioService {
    private $account_sid;
    private $auth_token;
    private $twilio_number;
    private $client;

    public function __construct() {
        $this->account_sid = 'VOTRE_ACCOUNT_SID'; // À remplacer par votre SID Twilio
        $this->auth_token = 'VOTRE_AUTH_TOKEN';    // À remplacer par votre token Twilio
        $this->twilio_number = 'VOTRE_NUMERO_TWILIO'; // Format: +1234567890
        
        $this->client = new Client($this->account_sid, $this->auth_token);
    }

    public function sendSMS($to, $message) {
        try {
            // Nettoyer et formater le numéro
            $to = $this->formatPhoneNumber($to);
            
            $this->client->messages->create(
                $to,
                [
                    'from' => $this->twilio_number,
                    'body' => $message
                ]
            );
            return ['success' => true, 'message' => 'SMS envoyé avec succès'];
        } catch (Exception $e) {
            error_log("Erreur d'envoi SMS: " . $e->getMessage());
            return [
                'success' => false, 
                'message' => 'Erreur lors de l\'envoi du SMS: ' . $e->getMessage()
            ];
        }
    }

    private function formatPhoneNumber($phone) {
        // Supprimer tous les caractères non numériques sauf le +
        $phone = preg_replace('/[^0-9+]/', '', $phone);
        
        // Si le numéro commence par 0, on le remplace par l'indicatif du Cameroun +237
        if (strpos($phone, '0') === 0) {
            $phone = '+237' . substr($phone, 1);
        }
        // Si le numéro commence par 6, 7, 8 ou 9 (sans indicatif), on ajoute +237
        elseif (preg_match('/^[6-9]/', $phone)) {
            $phone = '+237' . $phone;
        }
        // Si le numéro commence par 237, on ajoute le +
        elseif (strpos($phone, '237') === 0) {
            $phone = '+' . $phone;
        }
        
        return $phone;
    }
}

// Fonction utilitaire pour envoyer un SMS
function sendSms($to, $message) {
    $twilio = new TwilioService();
    return $twilio->sendSMS($to, $message);
}
