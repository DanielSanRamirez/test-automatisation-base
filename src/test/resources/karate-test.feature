Feature: Test de API súper simple

  Background:
    * configure ssl = true
    * url 'http://bp-se-test-cabcd9b246a5.herokuapp.com'
    * def basePath = '/testuser/api/characters'

  Scenario: Obtener lista de personajes
    Given path basePath
    When method get
    Then status 200
    And match response == '#[]'

  Scenario: Obtener personaje existente por ID
    * def personajeId = 220
    Given path basePath, personajeId
    When method get
    Then status 200
    And match response.id == personajeId

  Scenario: Obtener personaje inexistente
    * def personajeId = 0
    Given path basePath, personajeId
    When method get
    Then status 404
    And match response.error == 'Character not found'

  Scenario: Crear y luego eliminar personaje
    * def personaje =
      """
      {
        "name": "Cap America",
        "alterego": "Cris",
        "description": "Este personaje será creado y eliminado en 1 sola",
        "powers": ["Escudito", "Fuertote"]
      }
      """

    # Crear personaje
    Given path basePath
    And request personaje
    When method post
    Then status 201
    * def personajeId = response.id
    * karate.log('ID del personaje creado:', personajeId)

    # Eliminar personaje
    Given path basePath, personajeId
    When method delete
    Then status 204

    # Validar que ya no existe
    Given path basePath, personajeId
    When method get
    Then status 404

  Scenario: Crear personaje con nombre duplicado
    * def personaje =
      """
      {
        "name": "Capitan America Negrito 2",
        "alterego": "Un nombre Random",
        "description": "Personaje para prueba temporal",
        "powers": [
          "Red",
          "Blue"
        ]
      }
      """
    Given path basePath
    And request personaje
    When method post
    Then status 400
    And match response.error == 'Character name already exists'

  Scenario: Crear personaje con campos vacíos
    * def personaje =
      """
      {
        "name": "",
        "alterego": "",
        "description": "",
        "powers": []
      }
      """
    Given path basePath
    And request personaje
    When method post
    Then status 400
    And match response.name == 'Name is required'
    And match response.alterego == 'Alterego is required'
    And match response.description == 'Description is required'
    And match response.powers == 'Powers are required'

  Scenario: Actualizar personaje existente
    * def personajeId = 753
    * def update =
      """
      {
        "name": "Capitan America Negrito 3",
        "alterego": "Un nombre Random para el negrito 3",
        "description": "Personaje para prueba temporal No me borren porfas",
        "powers": [
          "Red",
          "Blue"
        ]
      }
      """
    Given path basePath, personajeId
    And request update
    When method put
    Then status 200
    And match response.description == 'Personaje para prueba temporal No me borren porfas'
    And match response.alterego == "Un nombre Random para el negrito 3"

  Scenario: Actualizar personaje inexistente
    * def personajeId = 1
    * def update =
      """
      {
        "name": "Capitan America Negrito 3",
        "alterego": "Un nombre Random para el negrito 3",
        "description": "Personaje para prueba temporal No me borren porfas",
        "powers": [
          "Red",
          "Blue"
        ]
      }
      """
    Given path basePath, personajeId
    And request update
    When method put
    Then status 404
    And match response.error == 'Character not found'