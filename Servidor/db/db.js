// db/db.js
const mysql = require('mysql2/promise');

// Configuración de la conexión MySQL
const dbConfig = {
  host: 'localhost',        // tu host MySQL
  port: 3306,               // puerto MySQL
  user: 'root',             // tu usuario
  password: '',             // tu contraseña
  database: 'rpgdatabase'   // nombre de tu base de datos
};

// Función para obtener la conexión a la base de datos
async function getConnection() {
  try {
    const connection = await mysql.createConnection(dbConfig);
    console.log('Conexión a la base de datos exitosa');
    return connection;
  } catch (error) {
    console.error('Error al conectar con la base de datos:', error);
    throw error;
  }
}

// Exporta la función para usarla en otros archivos
module.exports = {
  getConnection,
};
