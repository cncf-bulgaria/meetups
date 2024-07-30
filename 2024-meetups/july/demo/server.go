package main

import (
    "database/sql"
    "encoding/json"
    "fmt"
    "log"
    "net/http"

    _ "github.com/go-sql-driver/mysql"
    "github.com/spf13/viper"
)

type Employee struct {
    ID        int     `json:"id"`
    Name      string  `json:"name"`
    Position  string  `json:"position"`
    Salary    float64 `json:"salary"`
    HireDate  string  `json:"hire_date"`
}

type Config struct {
    DBHost    string `mapstructure:"db_host"`
    DBPort    string `mapstructure:"db_port"`
    DBUser    string `mapstructure:"db_user"`
    DBPass    string `mapstructure:"db_pass"`
    DBName    string `mapstructure:"db_name"`
    IPAddress string `mapstructure:"ip_address"`
}

func getEmployees(db *sql.DB) ([]Employee, error) {
    rows, err := db.Query("SELECT id, name, position, salary, hire_date FROM employee")
    if err != nil {
        return nil, err
    }
    defer rows.Close()

    var employees []Employee
    for rows.Next() {
        var emp Employee
        if err := rows.Scan(&emp.ID, &emp.Name, &emp.Position, &emp.Salary, &emp.HireDate); err != nil {
            return nil, err
        }
        employees = append(employees, emp)
    }
    return employees, nil
}

func employeesHandler(db *sql.DB) http.HandlerFunc {
    return func(w http.ResponseWriter, r *http.Request) {
        employees, err := getEmployees(db)
        if err != nil {
            http.Error(w, "Error fetching employees", http.StatusInternalServerError)
            return
        }
        w.Header().Set("Content-Type", "application/json")
        json.NewEncoder(w).Encode(employees)
    }
}

func rootHandler(w http.ResponseWriter, r *http.Request) {
    w.WriteHeader(http.StatusOK)
    w.Write([]byte("I am ready"))
}

func readConfig() (Config, error) {
    var config Config

    viper.AddConfigPath("./conf")
    viper.SetConfigName("config")
    viper.SetConfigType("yaml")

    if err := viper.ReadInConfig(); err != nil {
        return config, err
    }

    if err := viper.Unmarshal(&config); err != nil {
        return config, err
    }

    return config, nil
}

func main() {
    config, err := readConfig()
    if err != nil {
        log.Fatalf("Error reading config: %v", err)
    }

    dsn := fmt.Sprintf("%s:%s@tcp(%s:%s)/%s?parseTime=true", config.DBUser, config.DBPass, config.DBHost, config.DBPort, config.DBName)
    fmt.Println(dsn)

    db, err := sql.Open("mysql", dsn)
    if err != nil {
        log.Fatal(err)
    }
    defer db.Close()

    serverAddress := fmt.Sprintf("%s:%s", config.IPAddress, "8080")
    http.HandleFunc("/", rootHandler)
    http.HandleFunc("/employees", employeesHandler(db))
    fmt.Printf("Server is running on http://%s\n", serverAddress)
    log.Fatal(http.ListenAndServe(serverAddress, nil))
}
